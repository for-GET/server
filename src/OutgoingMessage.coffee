define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'stream'
], (
  {Writable}
) ->
  "use strict"

  #
  class OutgoingMessage extends Writable
    socket: undefined
    protocol: 'HTTP'
    version: undefined
    status: undefined
    headers: undefined
    representation: undefined
    chosen: undefined


    constructor: ({socket}) ->
      super {encoding: 'ascii'}
      @socket = socket
      @headers = []
      @chosen =
        contentType: undefined
        language: undefined
        charset: undefined
        encoding: undefined
      return  unless @socket?
      @socket.setEncoding 'ascii'


    destroy: (error) ->
      @socket.destroy error  if @socket?
