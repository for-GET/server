prefix = './lib'
prefix = './src'  if /\.coffee$/.test module.filename

module.exports =
  Resource: require "#{prefix}/Resource"
  Server: require "#{prefix}/Server"
