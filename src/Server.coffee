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
    _stack: undefined


    _connectionListener: (socket) ->
      transaction = new Transaction {socket}
      transaction.request.on 'line', () =>
        @_handleTransaction {transaction}


    _clientErrorListener: (err, socket) ->
      socket.destroy err


    _handleTransaction: ({transaction}) =>
      {request, response} = transaction
      for {path, keys, handler} in @_stack
        match = path.exec request.target
        continue  if match is null
        match.shift()
        kv = {}
        kv[name] = match[index]  for {name}, index in keys
        request.keys = kv
        handler request, response
        return


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


    constructor: () ->
      @_stack = []
      @addListener 'connection', @_connectionListener
      @addListener 'clientError', @_clientErrorListener


    use: (path, handler) ->
      keys = []
      path = @_pathRegExp path, keys
      @_stack.push {
        path
        keys
        handler
      }
