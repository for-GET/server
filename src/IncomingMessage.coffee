define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  './Message'
  'api-pegjs'
], (
  {_, noop, BufferIndexOf}
  Message
  api
) ->
  "use strict"

  Request = api['http/Request']
  CRLF = '\r\n'

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Message
    _receiving: undefined
    _buffer: ''
    # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
    _maxSizeLine: 1024 * 2
    _maxSizeHeaders: 1024 * 256
    _maxSizeBody: 1024 * 1024 * 10
    method: undefined
    target: undefined


    _transform: (chunk, encoding, next = noop) ->
      # FIXME implement chunked encoding
      unless chunk?.length > 1
        @push chunk
        return next()
      maxSize = @_maxSizeLine + @_maxSizeHeaders + @_maxSizeBody
      if @_socket.bytesRead > maxSize
        return @destroy new Error "Request is larger than #{maxSize} bytes"

      loop
        [stage, delimiter] = @_receiving
        if stage is 'body'
          @push chunk
          return next()
          # FIXME always skipping trailers

        chunk = Buffer.concat [@_buffer, chunk], @_buffer.length + chunk.length
        index = BufferIndexOf.call chunk, delimiter
        if index is -1
          @_buffer = chunk
          @push new Buffer ''
          return next()
        value = chunk.slice(0, index).toString()
        chunk = chunk.slice index + Buffer.byteLength delimiter

        if stage is 'line'
          @_rawLine = value
          request = new Request "#{@_rawLine}#{CRLF}#{CRLF}"
          @[prop] = request[prop]  for prop in [
            'version'
            'method'
            'target'
            'headers'
          ]
          @emit 'line'
          if chunk.slice(0, 2).toString() is CRLF
            @emit 'headers'
            @_receiving = ['body']
          else
            @_receiving = ['headers', CRLF + CRLF]
        else
          @_rawHeaders = value
          if value?.length
            request = new Request "#{@_rawLine}#{CRLF}#{@_rawHeaders}#{CRLF}#{CRLF}"
            @headers = request.headers
          @emit 'headers'
          @_receiving = ['body']


    constructor: ({socket, transaction}) ->
      super
      @_receiving = ['line', CRLF]
      @_buffer = new Buffer 0
      @_socket?.pipe @
