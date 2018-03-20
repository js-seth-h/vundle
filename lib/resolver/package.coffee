debug = require('debug') 'PackageResolver'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

util = require 'util'

class PackageResolver
  constructor: (@option = {})->
    for own k, v of @option
      this[k] = v

  init: (@vundler, @name)->
  visit: (chunk)->
    return unless chunk.fsStats
    return unless chunk.fsStats.isDirectory()
    test_path = path.join chunk.abs_path, 'package.json'
    stat = await do util.promisify (cb)->
      fs.stat test_path, (err, stat)-> cb null, stat
    # debug 'test_path', test_path, stat
    if stat
      chunk.abs_path = test_path
      chunk.fsStats = stat

module.exports = PackageResolver
