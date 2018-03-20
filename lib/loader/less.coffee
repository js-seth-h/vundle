debug = require('debug') 'Override'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'


util = require 'util'

less = require("less");
class Less
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.less'
    # debug 'parse LESS', chunk.content
    opt = {}
    result = await do util.promisify (cb)->
      less.render chunk.content.toString(), cb
    chunk.content = result.css.toString()
    chunk.ext = '.css'

    # debug 'LESS to CSS', chunk.content



module.exports = Less
