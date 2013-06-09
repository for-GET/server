chai = require 'chai'
chai.Assertion.includeStack = true

exports.should = chai.should()

console.jog = (arg) ->
  console.log JSON.stringify arg
