define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'stream'
], (
  {Readable}
) ->
  "use strict"

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Readable
    maxSize: 0 +      # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
      1024 * 2 +      # request-line
      1024 * 256 +    # headers
      1024 * 1024 * 2 # body
    socket: undefined
    protocol: 'HTTP'
    version: undefined
    method: undefined
    scheme: undefined
    host: undefined
    target: undefined
    headers: undefined
    representation: undefined


    constructor: ({socket}) ->
      super {encoding: 'ascii'}
      @socket = socket
      return  unless @socket?
      @socket.setEncoding 'ascii'
      @socket.on 'end', () =>
        @push null
      @socket.on 'readable', () =>
        @read 0


    destroy: (error) ->
      @socket.destroy error  if @socket?


    _read: () ->
      chunk = @socket.read()
      return @push ''  unless chunk?
      return @socket.destroy new Error "Request is larger than #{@maxSize} bytes"   if @socket.bytesRead > @maxSize
      unless @target?
        CRLF = '\r\n'
        index = chunk.indexOf CRLF
        if index isnt -1
          requestLine = chunk.substr 0, index
          # FIXME optimistic
          [method, target, protocolVersion] = requestLine.split ' '
          @method = method
          @target = target
          @version = protocolVersion.replace 'HTTP/', ''
          @emit 'route', target
      @push chunk
