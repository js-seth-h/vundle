process.env.DEBUG = "*, -ficent"
debug = require('debug') "bundler"
_ = require 'lodash'
fs = require 'fs'
path = require 'path'
glob = require 'glob'

{Vundler, Section, resolver, loader, writer} = require "./vundler"

main = ()->
  output_dir = './dist/disk'
  input_dir = './'
  entry = "web-app"
  name = "bundle"

  SRC_DIRS = 'node_modules;shared;browser/vendors;browser/runtime;browser/webapp'

  bundler = new Vundler
    name: name
    watch_root: SRC_DIRS
    processors:
      AbsoluteResolver: new resolver.Absolute
        dirs : SRC_DIRS
        default_ext_pattern: "?(.js|.coffee)"
      RelativeScriptResolver:  new resolver.Relative
        default_ext_pattern: "?(.js|.coffee)"
      ModuleResolver: new resolver.Package
        default_ext_pattern: "?(.js|.coffee)"
      IndexResolver:  new resolver.Index
        default_ext_pattern: "?(.js|.coffee)"
      RelativeResolver:  new resolver.Relative
      PackageJsonOverride: new loader.PackageJsonOverride
        override: package_override
      PackageLoader:  new loader.Package
      CoffeeTrans: new loader.CoffeeScript
      # javascript:  new loader.Javascript
      RequireFinder:  new loader.RequireFinder
      JsonInScript:  new loader.JsonInScript
      HtmlTemplate:  new loader.HtmlInJavascript
      Less:  new loader.Less
      # Css:  new loader.Css
      CssFileExtractor:  new loader.CssFileExtractor
    sections:
      script: new Section
        # 우선 요구되는 파일을 찾고, 그다음 쓰기 처리
        resolvers: "AbsoluteResolver,RelativeScriptResolver,ModuleResolver,IndexResolver" # ,,,IndexResolver"
        loaders: "PackageJsonOverride,PackageLoader,CoffeeTrans,HtmlTemplate,JsonInScript,RequireFinder" # ,,javascript,"
        writer: new writer.Javascript
          output_dir: output_dir  #"./dist/disk/"
          output: "disk.#{name}.js"

      style: new Section
        resolvers: "RelativeResolver"
        loaders: "Less,CssFileExtractor"
        arrange: (list)->
          list = _.reverse list
          less1 = _.remove list, (a)-> a.ref_id is 'ux/font.less'
          less2 = _.remove list, (a)-> _.endsWith a.ref_id, 'normalize.less'
          less3 = _.remove list, (a)-> _.startsWith a.ref_id, 'flatcss'
          _.concat less1, less2, less3, list

        writer: new writer.CssWriter
          output_dir: output_dir
          output: "disk.#{name}.css"

      file: new Section
        resolvers: "RelativeResolver"
        writer: new writer.FileWriter
          output_dir: output_dir

  bundler.initAsCli()
  bundler.script.write entry

main()
