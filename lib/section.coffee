debug = require('debug') 'section'

path = require 'path'
util = require 'util'
fs = require 'fs'
_ = require 'lodash'
require 'colors'


posixize = (path_string)->
  re_sep = /\\/g
  path_string.replace re_sep, '/'

class Section
  constructor: (option)->
    for own k, v of option
      this[k] = v
    @write_reqs = {}
    @files = {}
    @report = []
  init: (@vundler, @name)->
    vundler = @vundler
    _asProcesssor = (key)-> vundler.processors[key]
    @resolvers = _(@resolvers).split(',').map(_.trim).map(_asProcesssor).without(undefined).value()
    # debug 'resolvers', @resolvers
    @loaders = _(@loaders).split(',').map(_.trim).map(_asProcesssor).without(undefined).value()
    @writer.init @vundler, @name
    # debug 'loaders', @loaders

  hasJob:()->
    all_task = _.concat _.values(@files), _.values(@write_reqs)
    # debug 'all_task', _.filter all_task, 'in_processing'
    _.some all_task, (t)-> t.in_processing is true

  setDirty: (abs_path)->
    # debug 'p2=', p2, '<<', abs_path
    removed = []
    for own k, file of @files
      # p1 = path.normalize file.abs_path
      is_dirty = _.some file.dirty_checks, (chker)->
        chker abs_path
      if is_dirty
        debug 'detect Dirty at', file.ref_id
      # if file.dirty_checks.has abs_path
        # debug 'reload', file
        # file.in_processing = true
        # file.delete = true
        removed.push file
        delete @files[k]
        # @load file
    # _.remove @files

    for t in removed
      # @files[t.abs_path] =  @createFileChunk t
      # @load @files[t.abs_path]
      @writeForce t.ref_id

  createFileChunk: (file_chunk)->
    ref_id = posixize path.relative file_chunk.root_dir, file_chunk.abs_path
    obj =
      ref_id: ref_id
      root_dir: file_chunk.root_dir
      abs_path: file_chunk.abs_path
      fsStats: file_chunk.fsStats
      dirty_checks: []
    obj.dirty_checks.push (watch_path)-> _.eq watch_path, obj.abs_path
    return obj
  dumpToFile: ()->
    list = _.values @files
    if @arrange
      list = @arrange list
    @writer.writeAll list

    for log in @report
      debug log
    @write_reqs = {}
    @report = []
  writeForce: (pathname, referer = null)->
    wreq_id = "#{pathname} @ #{referer}"
    debug "in [#{@name}], write #{wreq_id}"
    wreq =
      write_context : wreq_id
      pathname: pathname
      referer: referer
      in_processing : true
    if referer
      file_chunk = @vundler.getFile referer
      unless file_chunk
        throw new Error 'cannot find referer by' + referer
      wreq.root_dir = file_chunk.root_dir # @files[referer].root_dir

    @write_reqs[wreq_id] = wreq
    process.nextTick ()=>
      @find wreq

  write: (pathname, referer = null)->
    wreq_id = "#{pathname} @ #{referer}"
    unless @write_reqs[wreq_id]
      @writeForce pathname, referer


  find: (wreq)->
    try
      await @getAbsPath wreq
      # debug 'get abs_path', wreq.abs_path
      unless wreq.abs_path
        wreq.not_found = true
        wreq.in_processing = false
        @report.push "not found;", wreq.write_context
        return
        # throw new Error 'Not Found ' + "(#{wreq.pathname} at #{wreq.referer})"
      unless @files[wreq.abs_path]
        @files[wreq.abs_path] = @createFileChunk wreq
        @load @files[wreq.abs_path]
      wreq.in_processing = false

    catch error
      wreq.error = error
      @report.push "* find error;", error.toString(), wreq.write_context
      console.error 'Error in Write to ', @name, 'error =', error


  load: (file_chunk)->
    # debug 'load', file_chunk.abs_path
    try
      @vundler.StartWatchEach file_chunk.abs_path
      # debug 'readFile'
      file_chunk.ext = path.extname file_chunk.abs_path
      file_chunk.content = await do util.promisify (cb)->
        # opt = encoding:
        fs.readFile file_chunk.abs_path, cb

      # debug 'getTranspile'
      await @getTranspile file_chunk
      # debug 'get content', file_chunk
      file_chunk.in_processing = false
      @vundler.checkEnd()
    catch error
      @report.push "* load error;", error.toString(), file_chunk

      file_chunk.error = error
      console.error 'Error in Write to ', @name, 'error =', error
  getAbsPath: (wreq)->
    # debug '@resolvers', @resolvers
    for resolver in @resolvers
      # debug 'resolver', resolver.name
      await resolver.visit wreq
    if wreq.abs_path
      wreq.abs_path = path.normalize wreq.abs_path
    return wreq.abs_path

  getTranspile: (file_chunk)->
    # debug '@loaders', @loaders
    for loader in @loaders
      # debug 'loader',loader.name
      await loader.visit file_chunk
    return file_chunk.content


module.exports = Section
