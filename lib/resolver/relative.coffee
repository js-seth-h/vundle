debug = require('debug') 'RelativeResolver'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

glob = require 'glob'
util = require 'util'

class RelativeResolver
  constructor: (@option = {})->
    for own k, v of @option
      this[k] = v

  init: (@vundler, @name)->
  visit: (chunk)->
    return unless chunk.referer
    return if chunk.pathname[0] isnt '.'

    referer_dir = path.dirname chunk.referer
    test_path = path.join referer_dir, chunk.pathname
    if @default_ext_pattern
      test_path += @default_ext_pattern

    files = await do util.promisify (cb)->
      glob test_path, cb
    # debug 'relative test', test_path, files, chunk
    return unless _.first files
    chunk.abs_path = _.first files
    chunk.fsStats = await do util.promisify (cb)->
        fs.stat chunk.abs_path, cb

module.exports = RelativeResolver
