debug = require('debug') 'coffeescript'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'
cs = require 'coffeescript'


class CoffeeCompile
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.coffee'
    chunk.content = cs.compile chunk.content.toString(), {bare: true}
    chunk.ext = '.js'

module.exports = CoffeeCompile
