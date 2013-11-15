define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './IncomingMessage'
  './OutgoingMessage'
], (
  IncomingMessage
  OutgoingMessage
) ->
  "use strict"

  #
  class Transaction
    _socket: undefined
    request: undefined
    response: undefined


    constructor: ({socket}) ->
      @_socket = socket
      @request ?= new IncomingMessage {socket, transaction: @}
      @response ?= new OutgoingMessage {socket, transaction: @}


    destroy: (error) ->
      @request.destroy error  if @request?
      @response.destroy error  if @response?
      @_socket.destroy error  if @_socket?


    toJSON: () ->
      {
        socket: @_socket.address()
        request: @request.toJSON()
        response: @response.toJSON()
      }