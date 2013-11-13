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
      if @_rawHeaders
        fun()
      else
        @writeHead null, fun


    constructor: ({socket, transaction}) ->
      super
      @pipe @_socket


    setHeader: (name, value) ->
      return @emit 'error', 'Cannot set headers after they are sent'  if @_rawHeaders?
      nameLC = name.toLowerCase()
      return nameLC.set value  if _.has @h, nameLC
      @headers[nameLC] = headerFactory name, value


    writeHead: (args = {}, next = noop) ->
      {protocol, version, status_code, headers} = args
      return @emit 'error', new Error 'Headers are already sent'  if @_rawHeaders?
      @[prop] = args[prop]  for prop in [
        'protocol'
        'version'
        'status_code'
      ]
      if headers?
        @headers ?= []
        for name, value of headers
          @headers.push {
            __type: 'header_field'
            name
            value
          }
      response = new Response()
      response[prop] = @[prop]  if @[prop]?  for prop in [
        'version'
        'status_code'
        'headers'
      ]
      head = response.toString {hideBody: true}
      headersIndex = head.indexOf CRLF
      @_rawLine = head.slice 0, headersIndex
      @_rawHeaders = head.slice headersIndex + 1
      @push head
      next()


    end: (args...) ->
      super
      @_socket.end()
      @emit 'finish'
