module.exports =
  port: 8000
  use: [
    ['/', require('../').Resource.middleware()]
  ]
