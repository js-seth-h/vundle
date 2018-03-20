process.env.DEBUG = "*, -ficent"
debug = require('debug') 'build'


glob = require 'glob'
path = require 'path'
_ = require 'lodash'


modulesFrom = (dir)->
  modules = {}
  for p in glob.sync path.join __dirname, "./lib/#{dir}/*.coffee"
    bn = path.basename p, path.extname p
    bn = _.upperFirst _.camelCase bn
    modules[bn] = require p
    # console.log bn, p
  return modules

module.exports = exports =
  Vundler: require './lib/vundler2'
  Section: require './lib/section'
  writer: modulesFrom 'writer'
  resolver : modulesFrom 'resolver'
  loader : modulesFrom 'loader'
