debug = require('debug') 'FileWriter'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'



mkdirp = require 'mkdirp'



class FileWriter
  constructor: (@option)->
    @section = 'file'
    for own k, v of @option
      this[k] = v

  init: (@vundler, @name)->

  writeAll: (files)->
    # output_name = path.join @output_dir,
    debug "------------------------------------------".green

    @write_count = 0
    @error_count = 0


    @openStream()
    for chunk in files
      if chunk.content
        @write chunk
        @write_count++
    #
    # for own k, pi of disk.resources
    #   if pi.section is @section
    #     if pi.getData().error
    #       # report_lines.push ['error'.red.bold, pi.cmdId.white]
    #       @error_count++
    #       has_error = true
    #       debug 'error '.red + pi.cmdId
    #       err_reports.push
    #         section: section
    #         cmdId: pi.cmdId
    #         error: pi.getData().error
    #     else
    #     # debug 'writer', pi.cmdId
    #       @write pi
    #       # report_lines.push report
    #       @write_count++
    @final()

    debug 'Write'.yellow, @name, '==>>', @output_dir
    debug 'Count', @write_count
    debug "------------------------------------------".green


  openStream: ()->
  final: ()->
  report: ()->
    debug "write: #{@write_count}, error: #{@error_count.toString().red}"

  write : (chunk)->
    to_abs = path.join @output_dir, chunk.ref_id

    filecopy = require 'filecopy'
    promise = filecopy chunk.abs_path, to_abs,
      mkdirp: true

    kb = (chunk.fsStats.size / 1024).toFixed 2
    debug "#{kb.toString().white} kb #{chunk.ref_id}"



module.exports = FileWriter
