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
  headerFactory = api['http/headers/factory']
  CRLF = '\r\n'
  lineDelimiter = CRLF
  headersDelimiter = CRLF + CRLF

  # based on https://github.com/isaacs/readable-stream
  #
  class IncomingMessage extends Message
    _receiving: undefined
    _buffer: undefined
    # http://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers
    _maxSizeLine: 1024 * 2
    _maxSizeHeaders: 1024 * 256
    _maxSizeBody: 1024 * 1024 * 10
    dispatch: undefined
    method: undefined
    target: undefined


    _storeLine: (value) ->
      @_rawLine = value
      request = new Request "#{@_rawLine}#{CRLF}"
      @[prop] = request[prop]  for prop in [
        'version'
        'method'
        'target'
      ]
      @emit 'line', @_rawLine
      @_receiving = 'headers'


    _storeHeader: (value) ->
      @_rawHeaders ?= ''
      @_rawHeaders += value
      @emit 'header', value


    _storeHeaders: () ->
      {headers} = new Request "#{@_rawLine}#{@_rawHeaders}#{CRLF}"
      for header in headers
        name = header.name.toLowerCase()
        @headers[name] = headerFactory name, header.value
        contentField = @_contentTransferRE.exec(name)?[2]
        @chosen[contentField] = @headers[name]  if contentField?
      @emit 'headers', @_rawHeaders
      @_receiving = 'body'


    _transform: (chunk, encoding, next = noop) ->
      # FIXME implement chunked encoding
      unless chunk?.length > 1
        @push chunk
        return next()
      maxSize = @_maxSizeLine + @_maxSizeHeaders + @_maxSizeBody
      if @_socket.bytesRead > maxSize
        return @destroy new Error "Request is larger than #{maxSize} bytes"

      loop
        if @_buffer.length
          chunk = Buffer.concat [@_buffer, chunk], @_buffer.length + chunk.length
          @_buffer = new Buffer 0

        if @_receiving is 'body'
          @push chunk
          return next()
          # FIXME always skipping trailers

        index = BufferIndexOf.call chunk, CRLF
        if index is -1
          @_buffer = chunk
          @push new Buffer ''
          return next()

        index += Buffer.byteLength CRLF
        value = chunk.slice(0, index).toString()
        chunk = chunk.slice index

        switch @_receiving
          when 'line'
            @_storeLine value
            @_buffer = chunk
          when 'headers'
            if value?.length
              @_storeHeader value
              @_buffer = chunk
            else
              @_storeHeaders


    constructor: ({socket, transaction}) ->
      super
      @dispatch =
        keys: undefined
        path: undefined
      @_receiving = 'line'
      @_buffer = new Buffer 0
      @_socket?.pipe @


    destroy: (error) ->
      @_socket?.unpipe @
      super


    toJSON: () ->
      result = super
      _.merge result, {
        @_receiving
        @method
        @target
        @dispatch
      }