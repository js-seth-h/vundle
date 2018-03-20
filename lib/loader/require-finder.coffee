debug = require('debug') 'RequireFinder'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

glob = require 'glob'
requires = require('requires')

class RequireFinder
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    results = requires chunk.content.toString()
    for match in results
      pathname = match.path
      @vundler.write 'script', pathname, chunk.abs_path



module.exports = RequireFinder
