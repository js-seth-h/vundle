###

  entry 규칙

  파일은 풀 위치를 쓴다.
  디렉토리는 /로 끝나야한다.


###

globalScope = ->
  window or process or global

disk_entry = (entry_path, loader)->
  disk = globalScope().disk = globalScope().disk or {}
  if disk[entry_path]
    # throw new Error 'Entry Crash!!! ' + entry_path
    e = new Error 'Entry Crash!!! ' + entry_path
    # console.error e.stack
    return


  disk[entry_path] =
    path : entry_path
    # exports: null
    definition : loader
  # # console.log 'set entry', entry_path



createEvent = (name)->
  if typeof Event == 'function'
    event = new Event name
  else
    event = document.createEvent('Event')
    event.initEvent name, true, true
  return event
check_entry = (entry_path, desc)->
  unless entry_path
    disk = globalScope().disk
    console.log 'entries', disk
    document.dispatchEvent createEvent 'check_entry'
  else
    document.addEventListener 'check_entry', ()->
      try
        module =  getModule entry_path
      catch e
        e = new Error "Entry Not Exist. " + entry_path
        console.warn e, desc


# splitPathRe = /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
# posixSplitPath = (filename) ->
#   out = splitPathRe.exec(filename)
#   out.shift()
#   return out

dirname = (path) ->
  result = path.split '/'
  return result[...-1].join '/'

  # dir = result[1]
  # if !root and !dir
  #   # No dirname whatsoever
  #   return '.'
  # if dir
  #   # It has a dirname, strip trailing slash
  #   dir = dir.substr(0, dir.length - 1)
  # root + dir

resolve = (from, paths...)->
  dir_arr = from.split '/'
  for p in paths
    toks = p.split '/'
    for t in toks
      if t is '..'
        dir_arr.pop()
      else if t is '.'
      else
        dir_arr.push t
  dir_arr.join '/'

resolveEntry = (request, parent)->
  disk_entry = request
  start = request[0...2]
  # # # console.log  'start =', start
  if start isnt './' and start isnt '..'
    # 정적 링크
    return disk_entry


  dir = dirname parent.path
  # # console.log 'dir  =', dir, 'from', parent.path
  disk_entry = resolve dir, request
  # console.log 'resolve disk_entry ', disk_entry , 'by', request, 'from', parent.path
  return disk_entry

getModule = (abs_request)->

  abs_request_re = abs_request.replace(/([|()\[{.+*?^$\\])/g,"\\$1");


  # regexp = new RegExp  "^#{abs_request_re}((/|/index(\\..+?))|(\\..+?))?$", 'gi'
  regexp = new RegExp  "^#{abs_request_re}(\\.js)?(/package.json|(\\.[^\\./]+?)|/index(\\.[^\\./]+?))?$", 'gi'
  # 모듈명이 .js로 끝날수있고, /package.json로 끝나거나 .xxx로 끝나거나. /index.xxx로 끝나거나
  # # console.log 'getModule', abs_request, regexp
  for own entry, module of globalScope().disk
    is_match = regexp.test(entry)
    # # # console.log  'find module', is_match, entry
    if is_match
      # # # console.log  'matches', entry
      return module
  console.warn new Error "require '#{abs_request}' is not found."
  return undefined
  # console.log(error.stack)
  # throw error
# getModule = (abs_request)->
#   return globalScope().disk[abs_request]


require = (name) ->
  # # console.log "require(\"#{name}\")"
  abs_request = resolveEntry name
  # # console.log  '  => abs_request =', abs_request
  module = getModule abs_request
  unless module
    return undefined
  # # console.log 'require - resolve : ', module.path
  # module = disk[name]
  if not('exports' of module) and typeof module.definition == 'function'
    # # console.log 'call definition' , module.path
    require_in_moudle = (request)->
      # # console.log  'require_in_moudle', request
      # # console.log "require(\"#{request}\") in", module
      entry = resolveEntry request, module
      # # console.log "require(\"#{request}\") in", module, '==>>', entry
      require entry

    module.exports = {}
    module.definition.call this, module.exports, module, require_in_moudle, module.path, dirname module.path
    delete module.definition

  return module.exports
