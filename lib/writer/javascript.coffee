debug = require('debug') 'JavascriptWriter'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

moment = require 'moment'

UglifyJS = require("uglify-js")

mkdirp = require 'mkdirp'


class JavascriptWriter
  constructor: (option)->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  writeAll: (files)->
    output_name = path.join @output_dir, @output
    debug "------------------------------------------".green

    # @minify = disk.Manager.minify
    @write_count = 0
    @error_count = 0

    files = _.sortBy files, 'ref_id'
    @openStream output_name, files


    for chunk in files
      if chunk.content
        @write chunk
        @write_count++
    @final()
    debug 'Write'.yellow, @name, '==>>', output_name.yellow
    debug 'Count', @write_count
    debug "------------------------------------------".green


  openStream: (output_name, files)->
    mkdirp.sync @output_dir
    # fpath = path.join @output_dir, output_name
    @wstream = fs.createWriteStream output_name

    if @minify
      min_path = fpath.replace ".js", ".min.js"
      @min_wstream = fs.createWriteStream min_path


    @addDesc files
    @addRequire()
    @addBuildStamp()

  addBuildStamp : ()->
    dt_str = moment().local().format 'YYDDMM-HHmmss'
    script = """

      window.build_timestamp = "#{dt_str}";

    """
    @wstream.write script
    @min_wstream.write script if @minify


  addRequire: ()->

    filename = path.join __dirname, 'rsrc/disk-script.coffee'
    requireScript = fs.readFileSync filename, encoding : 'utf8'
    cs = require 'coffeescript'
    requireScript = cs.compile requireScript, {bare: true}
    @wstream.write requireScript
    @min_wstream.write requireScript if @minify

  addDesc: (files)->
    list = _.map files, (rsrc)->  "/* #{rsrc.ref_id} */"
    @wstream.write list.join '\n'
    # @min_wstream.write list.join '\n' if @minify

  final: ()->
    @wstream.end()
    @min_wstream.end() if @minify
  report: ()->
    debug "write: #{@write_count}, error: #{@error_count.toString().red}"


  getSrcBlock: (chunk, script)->
    return """
    /****************************************************
    start of #{chunk.abs_path}
    */
    disk_entry("#{chunk.ref_id}", function(exports, module, require, __filename, __dirname) {

      #{script}

    })

    /* end of #{chunk.abs_path}
    */

    """
  write : (chunk)->
    # debug file.toString()
    # debug 'write js', resource.dest
    script = chunk.content.toString()
    # rel_path = posixize path.relative chunk.root_dir, chunk.abs_path
    # chunk.module_id = rel_path
    # return unless script

    # is_dir = ''
    # unless resource.mapping.file
    #   is_dir = '/'
    # resource.output_entry = resource.resource_id + is_dir

    # if @option.minify
    #   script = resource.getData().javascript_export_min
    @wstream.write @getSrcBlock chunk, script
    if @minify
      result = UglifyJS.minify script,
        fromString : true
      @min_wstream.write @getSrcBlock chunk, result.code

    javascript_length = script.length
    kb = (javascript_length / 1024).toFixed(2)

    debug "#{kb.toString().white} kb #{chunk.ref_id}"



module.exports = JavascriptWriter
