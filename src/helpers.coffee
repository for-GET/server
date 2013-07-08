define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'otw/like/NodeJS/url'
], (
  url
) ->
  "use strict"

  #
  reqToURI = (req) ->
    uri = req.originalUrl or req.url
    fqdn = uri.indexOf('://') isnt -1
    unless fqdn
      if req.connection.encrypted
        protocol = 'https'
      else
        protocol = req.headers['x-forwarded-proto'] or 'http'
      [hostname, port] = req.headers.host.split ':'
      unless port
        switch protocol
          when 'http' then port = '80'
          when 'https' then port = '443'
      port = ":#{port}"  if port
      uri = protocol + '://' + hostname + port + req.url
    uri = url.parse uri, false, true

    {
      source: req.originalUrl
      scheme: uri.protocol.replace ':', ''
      userinfo: uri.auth
      host: uri.hostname
      port: uri.port
      authority: "#{uri.auth}@#{uri.hostname}:@{uri.port}"
      path: uri.pathname
      query: uri.search
      fragment: uri.hash
    }


  #
  reqToMethod = (req) ->
    (req.originalMethod or req.method).toUpperCase()


  {
    reqToURI
    reqToMethod
  }
