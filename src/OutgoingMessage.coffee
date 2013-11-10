define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'stream'
  'api-pegjs'
], (
  {_}
  {Writable}
  api
) ->
  "use strict"

  Response = api['http/Response']

  #
  class OutgoingMessage extends Writable
    _head: ''
    socket: undefined
    protocol: 'HTTP'
    version: '1.1'
    status_code: undefined
    headers: undefined
    representation: undefined
    trailers: undefined


    Object.defineProperty @::, '_headersSent',
      get: () ->
        @_head.length > 0


    constructor: ({socket}) ->
      super {encoding: 'ascii', decodeStrings: false}
      @socket = socket
      @headers = []
      return  unless @socket?
      @socket.setEncoding 'ascii'


    destroy: (error) ->
      @socket.destroy error  if @socket?


    get: (name) ->
      return  unless @headers?
      name = name.toLowerCase()
      header = _.find @headers, (header) ->
        header.name.toLowerCase() is name
      return  unless header?
      header.value


    set: (name, value) ->
      throw new Error 'Cannot set headers are they are sent'  if @_headersSent
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


    writeHead: (args = {}) ->
      {protocol, version, status_code, headers} = args
      throw new Error 'Headers are already sent'  if @_headersSent
      @protocol = protocol  if protocol?
      @version = version  if version?
      @status_code = status_code  if status_code?
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
      @_head = response.toString {hideBody: true}
      @socket.write @_head, 'ascii'


    _write: (data, callback) ->
      # FIXME implement chunked encoding
      @writeHead()  unless @_headersSent
      @socket.write data, 'ascii', callback


    write: (data, callback) ->
      super data, 'ascii', callback


    end: (args...) ->
      @write.apply @, args
      @write '\r\n', () =>
        super
        @socket.end()
        @emit 'finish'
