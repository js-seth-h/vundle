debug = require('debug') 'Override'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

glob = require 'glob'

class Override
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    # debug 'override', chunk.abs_path,  path.basename(chunk.abs_path)
    return if path.basename(chunk.abs_path) isnt 'package.json'
    try
      json = chunk.json = JSON.parse chunk.content
      # debug 'check override', json.name
      override = @override[json.name]
      if override
        new_json = _.assign {}, json, override
        chunk.content = JSON.stringify new_json, null, 2
        # debug 'override json', json.name , chunk.content
    catch error
      debug 'err in override', error



module.exports = Override
