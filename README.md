# for-GET Server [![Build Status][2]][1]

for-GET Server is a reference implementation of an HTTP server running the for-GET Machine.

**This is part of a bigger effort: [for-GET HTTP](https://github.com/for-GET/README).**


## Status

This software is highly volatile; the v4 diagram has the same status.


## Usage

```bash
npm install for-get-server
```

```coffee
{
  Server
  Resource
} = require 'for-get-server'

class MyResource extends Resource
  content_types_provided: () ->
    {
      'text/html': () -> '123'
    }

app = new Server()
app.use '/', MyResource.middleware()
app.listen 8000
```

#### Shell

```bash
# Shortcut to start a server from a configuration file
for-get-server path_to_config
# Sample
make sample
```


## License

[Apache 2.0](LICENSE)


  [1]: https://travis-ci.org/for-GET/server
  [2]: https://travis-ci.org/for-GET/server.png
