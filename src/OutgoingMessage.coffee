define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  './Message'
  'api-pegjs'
], (
  {_, noop}
  Message
  api
) ->
  "use strict"

  Response = api['http/Response']
  headerFactory = api['http/headers/factory']
  CRLF = '\r\n'

  #
  class OutgoingMessage extends Message
    status_code: undefined


    _transform: (chunk, encoding, next = noop) ->
      # FIXME implement chunked encoding
      # FIXME always skipping trailers
      fun = () =>
        @push chunk
        next()
      if @_rawHeaders?
        fun()
      else
        @writeHead null, fun


    _flush: (next = noop) ->
      fun = () =>
        @_socket.end()
        @emit 'finish'
        next()
      if @_rawHeaders?
        fun()
      else
        @writeHead null, fun


    constructor: ({socket, transaction}) ->
      super
      @pipe @_socket  if @_socket?


    destroy: (error) ->
      @unpipe @_socket  if @_socket?
      super


    header: (name, value) ->
      return super  if value is undefined
      return @emit 'error', new Error 'Cannot set headers after they are sent'  if @_rawHeaders?
      nameLC = name.toLowerCase()
      return delete @headers[nameLC]  if value is null
      return @headers[nameLC].set value  if _.has @headers, nameLC
      @headers[nameLC] = headerFactory name, value


    content: (tag, value) ->
      tag = @_expandTag tag
      if value is undefined
        return @chosen[tag]
      else
        @chosen[tag] = headerFactory tag, value


    writeHead: (args = {}, next = noop) ->
      {protocol, version, status_code, headers} = args
      return @emit 'error', new Error 'Headers are already sent'  if @_rawHeaders?
      for prop in [
        'protocol'
        'version'
        'status_code'
      ]
        continue  unless args[prop]?
        @[prop] = args[prop]
      if headers?
        @header name, value  for name, value of headers
      response = new Response()
      for prop in [
        'version'
        'status_code'
        'headers'
      ]
        continue  unless @[prop]?
        response[prop] = @[prop]
      {line, headers} = response.toString {split: true}
      @_rawLine = line
      @_rawHeaders = headers
      headers = CRLF + headers  if headers.length
      @push line + headers + CRLF + CRLF
      next()


    writeStatus: (args = {}, next = noop) ->
      {status_code} = args
      return  unless status_code?
      return @emit 'error', new Error 'Headers are already sent'  if @_rawHeaders?
      response = new Response()
      response.status_code = status_code
      {line} = response.toString {split: true}
      line = line + CRLF
      @push line
      next()
