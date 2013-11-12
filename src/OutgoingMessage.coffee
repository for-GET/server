define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
  'api-pegjs'
], (
  {_, noop}
  {Transform}
  api
) ->
  "use strict"

  Response = api['http/Response']
  CRLF = '\r\n'

  #
  class OutgoingMessage extends Transform
    _rawLine: ''
    _rawHeaders: ''
    _socket: undefined
    protocol: 'HTTP'
    version: '1.1'
    status_code: undefined
    headers: undefined
    representation: undefined
    trailers: undefined


    constructor: ({socket}) ->
      super()
      @_socket = socket
      @headers = []
      @pipe @_socket


    destroy: (error) ->
      @_socket?.destroy error


    get: (name) ->
      return  unless @headers?
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value


    set: (name, value) ->
      throw new Error 'Cannot set headers are they are sent'  if @_rawHeaders
      @headers ?= []
      if @headers.length
        name = name.toLowerCase()
        header = _.find @headers, (header) ->
          header.name.toLowerCase() is name
        if header?
          header.value = value
          return

      @headers.push {
        _type: 'header_field'
        name
        value
      }


    writeHead: (args = {}, next = noop) ->
      {protocol, version, status_code, headers} = args
      return @emit 'error', new Error 'Headers are already sent'  if @_rawHeaders
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


    end: (args...) ->
      super
      @_socket.end()
      @emit 'finish'
