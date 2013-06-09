define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'http'
  'know-your-http-well'
], (
  http
  httpWell
) ->
  "use strict"

  status = httpWell.statusPhrasesToCodes

  #
  class ServerResponse extends http.ServerResponse
    self = @


    @patchNative: (res) ->
      res.prototype = self
      res._headers ?= {}
      # Disable automation
      res.sendDate = false
      res._hasBody = true
      res


    constructor: () ->
      super
      self.patchNative @


    writeHead: (statusCode, reasonPhrase, headers) ->
      if typeof reasonPhrase isnt 'string'
        reasonPhrase = undefined
        headers = arguments[1]
      # Use proper reason phrases
      reasonPhrase = status[statusCode] or reasonPhrase
      super statusCode, reasonPhrase, headers

      # Disable automation
      @_hasBody = true
