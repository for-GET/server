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
      uri = helpers.reqToURI req
      @transaction = {
        _req: req
        _res: res
        request:
          method: helpers.reqToMethod req
          scheme: uri.scheme
          host:
            source: req.headers.host
            hostname: uri.host
            port: uri.port
          target:
            source: req.url
            path: uri.path
            query: uri.query
          headers: req.headers
          representation: req.body
          h: {}
        response:
          status: undefined
          headers: res._headers
          representation: undefined
          h: {}
          chosen:
            contentType: undefined
            language: undefined
            charset: undefined
            encoding: undefined
        error:
          describedBy: undefined
          supportId: undefined
          title: undefined
          detail: undefined
      }
      super @transaction
