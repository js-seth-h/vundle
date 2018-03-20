debug = require('debug') 'processor.CssFileExtractor'
fs = require 'fs'
path = require('path')
ficent = require 'ficent'
_ = require 'lodash'
require 'colors'

posixize = (path_string)->
  re_sep = /\\/g
  path_string.replace re_sep, '/'

class CssFileExtractor
  constructor: (option = {})->
    for own k, v of option
      this[k] = v

  init: (@vundler, @name)->

  visit: (chunk)->
    return if chunk.ext isnt '.css'
    @readCss chunk
  readCss: (chunk)->
    # debug 'readCss', chunk.abs_path
    self = this
    # debug 'readCss ', resource.src_path, resource.dest
    # cssPropertyMatcher = /@import[^;]*|[;\s]?\*?[a-zA-Z\-]+\s*\:\#?[^;}]*url\(\s*['"]?[^'"\)\s]+['"]?\s*\)[^;}]*/g;
    urlMatcher = /url\(\s*['"]?([^)'"]+)['"]?\s*\)/g;
    chunk.content = chunk.content.toString().replace urlMatcher, (full_str, justURL)->
      # debug 'find url ', arguments
      # return urlFunc
      reUrl = self.rewriterFn chunk, justURL
      if reUrl
        changed_url = full_str.replace justURL, reUrl
        debug 'replace', full_str
        debug '     ->', changed_url
        return changed_url
      return full_str
  readCss_import_only: (chunk)->
    self = this
    # debug 'readCss ', resource.src_path, resource.dest
    cssPropertyMatcher = /@import[^;]*|[;\s]?\*?[a-zA-Z\-]+\s*\:\#?[^;}]*url\(\s*['"]?[^'"\)\s]+['"]?\s*\)[^;}]*/g;
    urlMatcher = /url\(\s*['"]?([^)'"]+)['"]?\s*\)/g;
    chunk.content = chunk.content.toString().replace cssPropertyMatcher, (matched_string)->
      # debug 'CssFileExtractor', matched_string

      debug 'find url ', matched_string
      overwrite = null
      m = matched_string.replace urlMatcher, (urlFunc, justURL)->
        reUrl = self.rewriterFn chunk, justURL
        if reUrl is ''
          overwrite = ''
        return urlFunc.replace justURL, reUrl

      debug 'replace url',  matched_string
      debug '  ->', m
      return overwrite ? m


  rewriterFn: (chunk, uri)->
    isData = (url) ->
      0 == url.indexOf('data:')
    isAbsolute = (url) ->
      ~url.indexOf('://') or '/' == url[0]

    isFragment = (url) ->
      !url.indexOf('#')

    return  if isData(uri)
    return  if isAbsolute(uri)
    return  if isFragment(uri)

    {pathname} = require('url').parse uri
    if pathname[0] isnt '.'
      pathname = './' + pathname

    if path.extname(pathname) is '.css'
      # d = disk.demand 'css', pathname, resource
      @vundler.write 'style', pathname, chunk.abs_path
      return
    else
      @vundler.write 'file', pathname, chunk.abs_path
      file_abs_path =  path.resolve chunk.abs_path, '..', pathname

      return posixize path.relative chunk.root_dir, file_abs_path

      # re_locate = path.join path.dirname(resource.mappingPath()), pathname
      # return re_locate


module.exports = CssFileExtractor
