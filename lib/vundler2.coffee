debug = require('debug') 'Vundler'
info = require('debug') 'INFO'

_ = require 'lodash'
require 'colors'

path = require 'path'
fs = require 'fs'
glob = require 'glob'

# Demand = require './demand'
# Resource = require './resource'
argv = require('minimist')(process.argv.slice(2));
debounce = require 'debounce'
lazyFn = (fn)-> debounce fn, 50

#
# {EventEmitter} = require 'events'

class Vundler # extends EventEmitter
  constructor: (option)->
    # super()
    for own k, v of option
      this[k] = v
    @dirty_list = []
  init: ()->
    for own name, processor of @processors
      # debug 'processor name', name, processor
      processor.init this, name
    for own name, section of @sections
      debug 'init section', name
      section.init this, name

    if @watch_mode is 'recursive'
      @watchOnTop = true
      @StartWatchOnTop()
    else if @watch_mode is 'each'
      @watchEach = true
      @watchers = {}
  initAsCli: ()->
    if argv.w
      @watch_mode = "recursive"
      if argv.e
        @watch_mode = "each"
    @init()
 
  StartWatchEach: (abs_path)->
    return unless @watchEach
    return if @watchers[abs_path]
    self = this
    @watchers[abs_path] = fs.watch abs_path, {}, (event, filename)->
      # abs_file = path.resolve abs_path, filename
      debug 'FsWatcher Each', event, filename # filename, 'by', dir_path
      self.setDirty abs_path

  StartWatchOnTop: ()->
    self = this
    opt = recursive: true

    debug 'StartWatchOnTop'
    dirs = _.split @watch_root, ';'
    _.forEach dirs, (dir_path)->
      dir_path = path.resolve dir_path
      fs.watch dir_path, opt, (event, filename)->
        unless filename
          debug 'WARNING', 'watch without filename', event, filename
          return;
        abs_file = path.resolve dir_path, filename
        debug 'FsWatcher', event, abs_file # filename, 'by', dir_path

        self.setDirty abs_file

  setDirty: (abs_path)->
    @dirty_list.push abs_path
    @flushDirty()
  flushDirty: lazyFn ()->
    list = _.uniq @dirty_list
    @dirty_list = []

    for own name, section of @sections
      for abs_path in list
        section.setDirty abs_path
  getFile:(abs_path)->
    for own name, section of @sections
      obj =  section.files[abs_path]
      return obj if obj
    return null
  checkEnd: lazyFn ()->
    self = this
    sections = _.values(@sections)
    # debug 'sections', this
    has_job = _.some sections, (sec)-> sec.hasJob()
    debug 'has_job?', has_job
    # process.exit()
    if has_job is false
      debug 'GOGOGO dump file'
      for own name, section of @sections
        section.dumpToFile()

module.exports = Vundler
