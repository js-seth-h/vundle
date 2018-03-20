debug = require('debug') 'CssWriter'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'



mkdirp = require 'mkdirp'



class CssWriter
  constructor: (@option)->
    @section = 'style'
    for own k, v of @option
      this[k] = v

  init: (@vundler, @name)->

  writeAll: (files)->
    output_name = path.join @output_dir, @output
    debug "------------------------------------------".green

    @write_count = 0
    @error_count = 0


    # @css_list = _.reverse _.values disk.resources

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
    @wstream = fs.createWriteStream output_name

    list = _.map files, (rsrc)->  "/* #{rsrc.ref_id} */"
    @wstream.write list.join '\n' 

  final: ()->
    @wstream.end()
  report: ()->
    debug "write: #{@write_count}, error: #{@error_count.toString().red}"
  write : (chunk)->
    # debug file.toString()
    # debug 'write css', resource.dest
    script = chunk.content.toString()
    script = """

    /****************************************************
    start of <#{chunk.abs_path}
    */

    #{script}

    /* end of <#{chunk.abs_path}> */
    """
    @wstream.write script


    write_length = script.length
    kb = (write_length / 1024).toFixed(2)

    debug "#{kb.toString().white} kb #{chunk.ref_id}"

module.exports = CssWriter
