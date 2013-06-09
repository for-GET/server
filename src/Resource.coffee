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


    # Methods
    method: () -> # :var
      overridenMethod = @operation._req.headers['x-http-method-override']
      return overridenMethod.toUpperCase()  if overridenMethod
      @operation.method
    safe_methods: () -> # :var
      [
        'HEAD'
        'GET'
        'OPTIONS'
        'TRACE'
      ]
    create_methods: () -> # :var
      [
        'POST'
        'PUT'
      ]
    process_methods: () -> # :var
      [
        'POST'
        'PATCH'
        'PUT'
        'DELETE'
      ]
    allowed_methods: () -> # :var
      @implemented_methods()


    # Implemented
    implemented_methods: () -> # :var
      [].concat @safe_methods(), @create_methods(), @process_methods()
    implemented_content_headers: () -> # :var
      [
        'content-encoding'
        'content-language'
        'content-length'
        'content-md5'
        'content-type'
      ]
    implemented_expect_extensions: () -> # :var
      [
        '100-continue'
      ]
    is_functionality_implemented: () -> # :bin
      true


    # Accepted
    post_content_types_accepted: () -> # :var
      {
        'application/x-www-form-urlencoded': () ->
          @context.entity = QueryString.parse @operation.representation
          true
      }
    patch_content_types_accepted: () -> # :var
      {}
    put_content_types_accepted: () -> # :var
      {}


    # Provided
    content_types_provided: () -> # :var
      {}
    default_content_type_provided: () -> # :var
      []
    languages_provided: () -> # :var
      {}
    default_language_provided: () -> # :var
      []
    charsets_provided: () -> # :var
      {
        'utf-8': (x) -> x
      }
    default_charset_provided: () -> # :var
      ['utf-8', @charsets_provided()['utf-8']]
    encodings_provided: () -> # :var
      {
        identity: (x) -> x
      }
    default_encoding_provided: () -> # :var
      ['identity', @encodings_provided().identity]
    error_content_types_provided: () -> # :var
      {}
    error_default_content_type_provided: () -> # :var
      []


    # Meta
    vary: () -> # :var
      result = []
      result.push 'accept'  if Object.keys(@content_types_provided()).length > 1
      result.push 'accept-charset'  if Object.keys(@charsets_provided()).length > 1
      result.push 'accept-encoding'  if Object.keys(@encodings_provided()).length > 1
      result.push 'accept-language'  if Object.keys(@languages_provided()).length > 1
      result
    etag: () -> # :var
      # FIXME
    last_modified: () -> # :var
      # FIXME
    expires: () -> # :var
      # FIXME
    cache: () -> # :var
      # FIXME


    # Misc
    is_uri_too_long: () -> # :bin
      false
    is_content_too_large: () -> # :bin
      false
    trace_sensitive_headers: () -> # :var
      [
        'authentication'
        'cookies'
      ]
    auth_challenges: () -> # :var
      [
        'PleaseSetAnAuthChallenge'
      ]
    is_authorized: () -> # :bin
      true
    is_forbidden: () -> # :bin
      false
    exists: () -> # :bin
      true
    existed: () -> # :bin
      false
    moved_permanently: () -> # :bin
      false
    moved_temporarily: () -> # :bin
      false
    path: () -> # :var
      undefined
    is_process_done: () -> # :bin
      true
    has_multiple_choices: () -> # :bin
      false
    need_camelcased_response_headers: () -> # :bin
      false


    # Process
    create_put: () -> # :bin
      false
    create: () -> # :bin
      false
    process_delete: () -> # :bin
      false
    process_put: () -> # :bin
      false
    process: () -> # :bin
      false


    # Override block
    is_request_ok: () -> # :bin
      true
    is_accept_ok: () -> # :bin
      true
    is_precondition_ok: () -> # :bin
      true


    # Override everything
    override: () -> # :bin
      true
