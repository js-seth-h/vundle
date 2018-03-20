debug = require('debug') 'HtmlInJavascript'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

class HtmlInJavascript
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.html'
    chunk.content = """
      module.exports = #{JSON.stringify chunk.content.toString()}
    """
    chunk.ext = '.js'

module.exports = HtmlInJavascript
