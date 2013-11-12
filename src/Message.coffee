define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
], (
  {_}
  {Transform}
) ->
  "use strict"

  class Message extends Transform
    _rawLine: undefined
    _rawHeaders: undefined
    _socket: undefined
    _transaction: undefined
    protocol: 'HTTP'
    version: '1.1'
    headers: undefined
    representation: undefined
    h: undefined


    constructor: ({socket, transaction}) ->
      super()
      @_socket = socket
      @_transaction = transaction
      @h = {}


    destroy: (error) ->
      @_socket?.destroy error


    get: (name) ->
      return  unless @headers?.length
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value


    getHeader: (name) ->
      name = name.toLowerCase()
      return @get name  unless _.has @h, name
      @h[name]
