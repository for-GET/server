define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
  'api-pegjs'
], (
  {_, noop, BufferIndexOf}
  {Transform}
  api
) ->
  "use strict"

  Request = api['http/Request']
  CRLF = '\r\n'

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Transform
    _receiving: undefined
    _buffer: ''
    _rawLine: undefined
    _rawHeaders: undefined
    # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
    _maxSizeLine: 1024 * 2
    _maxSizeHeaders: 1024 * 256
    _maxSizeBody: 1024 * 1024 * 10
    _socket: undefined
    protocol: 'HTTP'
    version: '1.1'
    method: undefined
    scheme: undefined
    host: undefined
    target: undefined
    headers: undefined
    representation: undefined
    trailers: undefined


    constructor: ({socket}) ->
      super()
      @_receiving = ['line', CRLF]
      @_buffer = new Buffer 0
      @_socket = socket
      @_socket?.pipe @


    destroy: (error) ->
      @_socket?.destroy error


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
            'scheme'
            'host'
            'target'
            'headers'
            'trailers'
          ]
          @emit 'line'
          @_receiving = ['headers', CRLF + CRLF]
        else
          @_rawHeaders = value
          if value?.length
            request = new Request "#{@_rawLine}#{CRLF}#{@_rawHeaders}#{CRLF}#{CRLF}"
            @headers = request.headers
          @emit 'headers'
          @_receiving = ['body']


    get: (name, types) ->
      types ?= ['header', 'trailer']
      return  unless @headers?
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value