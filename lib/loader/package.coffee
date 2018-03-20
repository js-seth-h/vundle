debug = require('debug') 'PackageJson'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

glob = require 'glob'
util = require 'util'
class PackageJson
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    # debug ' path.basename(chunk.abs_path)', path.basename(chunk.abs_path)
    return if path.basename(chunk.abs_path) isnt 'package.json'

    chunk.dirty_checks.push (watch_path)-> _.startsWith watch_path, path.dirname chunk.abs_path
    # debug 'dirty_checks', chunk.dirty_checks
    json = chunk.json = JSON.parse chunk.content

    if json.dependencies
      for own dep_name, semver of json.dependencies
        @vundler.write 'script', dep_name, chunk.abs_path

    if _.isString json.browser
      json.main = json.browser

    mainname = json.main or 'index'
    if mainname[0] isnt '.'
      mainname = './' + mainname

    @vundler.write 'script', mainname, chunk.abs_path
    script = """
      module.exports = require("#{mainname}")
      """
    chunk.content = script


    if json.bundler
      sections =
        script: _.compact [].concat json.bundler['scripts'], json.bundler['templates']
        style : _.compact [].concat json.bundler['styles']
        file: _.compact [].concat json.bundler['files'], json.bundler['fonts'], json.bundler['images']

      # debug 'sections', sections
      glob_list = _.flatten _.map sections, (patterns, sec_name)->
        _.map patterns, (p)->
          return obj =
            section: sec_name
            pattern: p
      # debug 'glob_list', glob_list

      vundler = @vundler
      package_dir = path.dirname chunk.abs_path
      for glob_opt in glob_list
        files = await do util.promisify (cb)->
          glob glob_opt.pattern, {nodir: true, cwd: package_dir}, cb

        _.map files, (f)->
          pathname = "./"+ f
          # debug 'write section = ', glob_opt.section
          vundler.write glob_opt.section, pathname, chunk.abs_path

module.exports = PackageJson
