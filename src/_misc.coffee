define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'lodash'
  'buffer'
], (
  _
  {Buffer}
) ->
  "use strict"

  {
    _


    BufferIndexOf: (searchValue, fromIndex = 0) ->
      index = -1
      return index  if fromIndex >= @length
      cursor = 0
      searchValue = new Buffer searchValue  if _.isString searchValue

      while true
        break  if cursor is searchValue.length
        break  if fromIndex + cursor > @length
        if searchValue[cursor] is @[fromIndex + cursor]
          index = fromIndex + cursor  if index is -1
          cursor += 1
        else
          index = -1
          fromIndex += cursor + 1
          cursor = 0
      index
  }