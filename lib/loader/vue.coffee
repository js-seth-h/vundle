debug = require('debug') 'coffeescript'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'
compiler  = require("vue-template-compiler")


class VueCompile
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.vue'
    parts = compiler.parseComponent(code)

    chunk.content = parts.script.content
    chunk.ext = '.js'

    #
    # parts = compiler.parseComponent(code)
    # console.log(parts.template)
    # console.log(parts.script)
    # console.log(parts.styles)
    # vundler.write glob_opt.section, pathname, chunk.abs_path


module.exports = VueCompile
