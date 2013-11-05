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
    req: undefined
    res: undefined


    constructor: ({socket}) ->
      @socket = socket
      @req = new IncomingMessage {socket}
      @res = new OutgoingMessage {socket}
      @req._res = @res
      @req._transaction = @
      @res._req = @req
      @res._transaction = @


    destroy: (error) ->
      @req.destroy error  if @req?
      @res.destroy error  if @res?
      @socket.destroy error  if @socket?
