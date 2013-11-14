define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
  'readable-stream/transform'
], (
  {_}
  {Transform}
  Transform8
) ->
  "use strict"

  Transform ?= Transform8

  class Message extends Transform
    _contentTransferRE: /^(content|transfer)\-(.+)/
    _rawLine: undefined
    _rawHeaders: undefined
    _socket: undefined
    _transaction: undefined
    protocol: 'HTTP'
    version: '1.1'
    headers: undefined
    representation: undefined
    chosen: undefined


    _expandTag: (tag) ->
      unless @_contentTransferRE.test tag
        if tag is 'encoding'
          tag = "transfer-#{tag}"
        else
          tag = "content-#{tag}"
      tag


    constructor: ({socket, transaction}) ->
      super()
      @_socket = socket
      @_transaction = transaction
      @headers = {}
      @chosen =
        encoding: undefined
        length: undefined
        range: undefined
        type: undefined
        charset: undefined
        language: undefined


    destroy: (error) ->
      @_socket?.destroy error


    header: (name) ->
      name = name.toLowerCase()
      @headers[name]


    content: (tag) ->
      tag = @_expandTag tag
      @chosen[tag]
