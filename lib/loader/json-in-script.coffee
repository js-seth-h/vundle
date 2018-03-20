debug = require('debug') 'HtmlInJavascript'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

class JsonInScript
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.json'
    chunk.content = """
      module.exports = #{chunk.content.toString()}
    """
    chunk.ext = '.js'


module.exports = JsonInScript
