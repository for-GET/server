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

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Readable
    _head: ''
    socket: undefined
    maxSize: 0 +      # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
      1024 * 2 +      # request-line
      1024 * 256 +    # headers
      1024 * 1024 * 2 # body
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
      chunk = @socket.read()
      return @push ''  unless chunk?
      return @socket.destroy new Error "Request is larger than #{@maxSize} bytes"   if @socket.bytesRead > @maxSize
      if @headers?
        @push chunk
        # FIXME always skipping trailers
      else
        chunk = @_head + chunk
        CRLF = '\r\n'
        suffixRequestLine = CRLF
        suffixHeaders = CRLF + CRLF

        # separate after request line or after headers
        _head = ''
        requestLine = ''
        headers = ''
        index = chunk.indexOf suffixRequestLine
        if index isnt -1
          _head = requestLine = chunk.substr 0, index
          chunk = chunk.substr index + suffixRequestLine.length
          index = chunk.indexOf suffixHeaders
          if index isnt -1
            headers = chunk.substr 0, index
            chunk = chunk.substr index + suffixHeaders.length
            _head += suffixRequestLine + headers
          _head += suffixHeaders
        if _head?
          request = new Request _head
          @[prop] = request[prop]  for prop in [
            'version'
            'method'
            'scheme'
            'host'
            'target'
          ]
          @emit 'line'  unless @headers
          if headers?
            @headers = request.headers
            @emit 'headers', @headers
            @push chunk
        else
          @_head += chunk
          @push ''


    get: (name, types) ->
      types ?= ['header', 'trailer']
      return  unless @headers?
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value