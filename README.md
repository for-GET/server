# HyperREST Server [![Build Status][2]][1]

[HyperREST](http://hyperrest.com) Server is a HTTP server on top NodeJS native HTTP server, using [HyperREST Machine](https://github.com/andreineculau/hyperrest-machine).

[HyperREST](http://hyperrest.com) Machine is a NodeJS implementation of the [HTTP decision diagram v4](https://github.com/andreineculau/http-decision-diagram/tree/master/v4).

In short, [I'm eating my own dog food](http://en.wikipedia.org/wiki/Eating_your_own_dog_food).

*Note* The interface of the HyperREST Server is similar to [connect](https://github.com/senchalabs/connect)/[express](https://github.com/visionmedia/express), but the compatibility these is not the utmost priority, nor goal.


## Status

This software is highly volatile; the v4 diagram has the same status.


## Usage

```bash
npm install hyperrest-server
```

```coffee
{
  Server
  Resource
} = require 'hyperrest-server'

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
hyperrest-server path_to_config
# Sample
make sample
```


## License

[Apache 2.0](LICENSE)


  [1]: https://travis-ci.org/andreineculau/hyperrest-server
  [2]: https://travis-ci.org/andreineculau/hyperrest-server.png
