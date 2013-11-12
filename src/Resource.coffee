define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  './_misc'
  'for-get-machine'
], (
  {_}
  machine
) ->
  "use strict"

  #
  class Resource extends machine.Resource
    @middleware: (Resource = @, FSM = machine.FSM) ->
      (transaction, next) ->
        resource = new Resource {transaction}
        new FSM resource


    constructor: ({transaction}) ->
      _.defaults transaction,
        error:
          describedBy: undefined
          supportId: undefined
          title: undefined
          detail: undefined
        log:
          transitions: []
          callbacks: []
      super
