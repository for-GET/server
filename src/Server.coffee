define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'http'
  './ClientRequest'
  './ServerResponse'
], (
  http
  ClientRequest
  ServerResponse
) ->
  "use strict"

  #
  class Server
    _ClientRequest: ClientRequest
    _ServerResponse: ServerResponse
    stack: undefined


    constructor: () ->
      @stack = []


    use: (route, handler) ->
      keys = []
      route = @_pathRegExp route, keys
      @stack.push {
        route
        keys
        handler
      }

      @


    handle: (req, res, port) =>
      @_patchReqRes req, res, port
      for {route, keys, handler} in @stack
        match = route.exec req.url
        continue  if match is null
        match.shift()
        kv = {}
        kv[name] = match[index]  for {name}, index in keys
        req.keys = kv
        handler req, res
        return


    listen: () ->
      [port] = arguments
      server = http.createServer (req, res) =>
        @handle req, res, port
      server.listen.apply server, arguments


    _patchReqRes: (req, res, port) ->
      @_ClientRequest.patchNative req
      @_ServerResponse.patchNative res
      req.app = res.app = @
      req.res = res
      res.req = req
      req.port = port


    ###
    # Copyright (c) 2009-2012 TJ Holowaychuk <tj@vision-media.ca>
    # MIT License
    # https://github.com/visionmedia/express/blob/master/lib/utils.js
    ###
    _pathRegExp: (path, keys, sensitive, strict) ->
      return path  if toString.call(path) is '[object RegExp]'

      keyFun = (_, slash, format, key, capture, optional, star) ->
        keys.push { name: key, optional: !! optional }
        slash = slash or ''
        (if optional then '' else slash) +
        '(?:' +
        (if optional then slash else '') +
        (format or '') + (capture or (format and '([^/.]+?)' or '([^/]+?)')) + ')' +
        (optional or '') +
        (if star then '(/*)?' else '')

      if Array.isArray path
        path = '(' + path.join('|') + ')'
      path = path
        .concat(if strict then '' else '/?')
        .replace(/\/\(/g, '(?:/')
        .replace(/(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?(\*)?/g, keyFun)
        .replace(/([\/.])/g, '\\$1')
        .replace(/\*/g, '(.*)')
      new RegExp '^' + path + '$', (if sensitive then '' else 'i')
