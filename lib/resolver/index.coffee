debug = require('debug') 'IndexResolver'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

glob = require 'glob'

util = require 'util'

class IndexResolver
  constructor: (@option = {})->
    for own k, v of @option
      this[k] = v

  init: (@vundler, @name)->
  visit: (chunk)->
    return unless chunk.fsStats
    return unless chunk.fsStats.isDirectory()

    test_path = path.join chunk.abs_path, 'index'
    if @default_ext_pattern
      test_path += @default_ext_pattern

    files = await do util.promisify (cb)->
      glob test_path, cb

    return unless _.first files
    chunk.abs_path = _.first files
    chunk.fsStats = await do util.promisify (cb)->
        fs.stat chunk.abs_path, cb

module.exports = IndexResolver
