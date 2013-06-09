define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'http'
], (
  http
) ->
  "use strict"

  #
  class ClientRequest extends http.ClientRequest
    self = @


    @patchNative: (req) ->
      req.prototype = self


    constructor: () ->
      super
      self.patchNative @
