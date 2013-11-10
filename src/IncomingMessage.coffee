define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
  'api-pegjs'
], (
  {_}
  {Readable}
  api
) ->
  "use strict"

  Request = api['http/Request']
  CRLF = '\r\n'

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Readable
    _receiving: undefined
    _buffer: ''
    _line: ''
    _headers: ''
    socket: undefined
    # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
    maxSizeLine: 1024 * 2
    maxSizeHeaders: 1024 * 256
    maxSizeBody: 1024 * 1024 * 2
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
      super {encoding: 'ascii'}
      @socket = socket
      @_receiving = ['line', CRLF]
      return  unless @socket?
      @socket.setEncoding 'ascii'
      @socket.on 'end', () =>
        @push null
      @socket.on 'readable', () =>
        @read 0


    destroy: (error) ->
      @socket.destroy error  if @socket?


    _read: () ->
      # FIXME implement chunked encoding
      chunk = @_buffer + @socket.read()
      return @push ''  unless chunk?
      maxSize = @maxSizeLine + @maxSizeHeaders + @maxSizeBody
      if @socket.bytesRead > maxSize
        return @socket.destroy new Error "Request body is larger than #{maxSize} bytes"
      @_buffer = ''
      if @_receiving[0] is 'body'
        @push chunk
        # FIXME always skipping trailers
      else
        delimiter = @_receiving[1]
        index = chunk.indexOf delimiter
        if index is -1
          @_buffer = chunk
          return @push ''
        value = chunk.substr 0, index
        chunk = chunk.substr index + delimiter.length
        if @_receiving[0] is 'line'
          @_line = value
          request = new Request "#{@_line}#{CRLF}#{CRLF}"
          @[prop] = request[prop]  for prop in [
            'version'
            'method'
            'scheme'
            'host'
            'target'
            'headers'
          ]
          @emit 'line'
          @_receiving = ['headers', CRLF + CRLF]
        else
          @_headers = value
          if value?.length
            request = new Request "#{@_line}#{CRLF}#{@_headers}#{CRLF}#{CRLF}"
            @headers = request.headers
          @emit 'headers'
          @_receiving = ['body']
        @_buffer = chunk
        @push ''
        if @_buffer?.length
          process.nextTick () => @read 0


    get: (name, types) ->
      types ?= ['header', 'trailer']
      return  unless @headers?
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value