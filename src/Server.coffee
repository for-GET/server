define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  #'api-pegjs'
  'net'
  './Transaction'
], (
  #api
  net
  Transaction
) ->
  "use strict"

  #
  class Server extends net.Server
    stack: undefined


    _connectionListener: (socket) ->
      transaction = new Transaction {socket}
      transaction.request.on 'line', () =>
        @handle {transaction}


    _clientErrorListener: (err, socket) ->
      console.log 'error'
      socket.destroy err


    constructor: () ->
      @stack = []
      @addListener 'connection', @_connectionListener
      @addListener 'clientError', @_clientErrorListener


    use: (route, handler) ->
      keys = []
      route = @_pathRegExp route, keys
      @stack.push {
        route
        keys
        handler
      }


    handle: ({transaction}) =>
      {request, response} = transaction
      # Example
      request.on 'data', (chunk) ->
        s = chunk
        #s = 'ß€'
        response.writeHead {headers: {'Content-Length': chunk.length}}
        response.write chunk
        response.end()
      return

      for {route, keys, handler} in @stack
        match = route.exec transaction.request.target
        continue  if match is null
        match.shift()
        kv = {}
        kv[name] = match[index]  for {name}, index in keys
        req.keys = kv
        handler req, res
        return


    _patchReqRes: (req, res) ->
      @_ClientRequest.patchNative req
      @_ServerResponse.patchNative res
      req.app = res.app = @
      req.res = res
      res.req = req


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
