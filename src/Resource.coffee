define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'querystring'
  'hyperrest-machine'
  './helpers'
], (
  QueryString
  machine
  helpers
) ->
  "use strict"

  #
  class Resource extends machine.Resource
    @middleware: (Resource = @, FSM = machine.FSM) ->
      (req, res, next) ->
        resource = new Resource req, res
        new FSM resource


    constructor: (req, res) ->
      @operation = {
        _req: req
        _res: res
        method: helpers.reqToMethod req
        uri: helpers.reqToURI req
        headers: req.headers
        representation: req.body
        h: {}
        response:
          statusCode: undefined
          headers: res._headers
          representation: undefined
          h: {}
          chosen:
            contentType: undefined
            language: undefined
            charset: undefined
            encoding: undefined
      }
      super @operation
