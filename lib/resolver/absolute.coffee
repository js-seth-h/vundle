debug = require('debug') 'AbsoluteResolver'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'
glob = require 'glob'

util = require 'util'

class AbsoluteResolver
  constructor: (@option = {})->
    for own k, v of @option
      this[k] = v

    @dirs = _.map _.split(@dirs, ';'), (dir)->
        path.resolve dir

    # debug '@dirs =', @dirs

  init: (@vundler, @name)->
  visit: (chunk)->
    return if chunk.pathname[0] is '.'
    for dir in  @dirs
      return if chunk.abs_path
      test_path = path.join dir, chunk.pathname
      if @default_ext_pattern
        test_path += @default_ext_pattern

      files = await do util.promisify (cb)->
        glob test_path, cb

      continue unless _.first files
      chunk.root_dir = dir
      chunk.abs_path = _.first files
      chunk.fsStats = await do util.promisify (cb)->
          fs.stat chunk.abs_path, cb
    return

module.exports = AbsoluteResolver
