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
    socket: undefined
    request: undefined
    response: undefined


    constructor: ({socket}) ->
      @socket = socket
      @request = new IncomingMessage {socket}
      @response = new OutgoingMessage {socket}
      @request._response = @response
      @request._transaction = @
      @response._request = @request
      @response._transaction = @


    destroy: (error) ->
      @request.destroy error  if @request?
      @response.destroy error  if @response?
      @socket.destroy error  if @socket?
