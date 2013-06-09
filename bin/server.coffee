#!/usr/bin/env coffee

Server = require('../').Server
app = new Server()

config = require process.argv[2]
config.port ?= process.env.port

for middleware in config.use
  app.use.apply app, middleware

s = app.listen config.port

console.log 'Listening on ' + JSON.stringify s.address()
