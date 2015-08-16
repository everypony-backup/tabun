path = require 'path'
webpack = require 'webpack'
{merge, keys} = require 'lodash'
pkginfo = require "./package.json"
ExtractTextPlugin = require 'extract-text-webpack-plugin'

module.exports =
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    vendor: keys(pkginfo.dependencies)

  output:
    path: path.join __dirname, 'static'
    publicPath: '/static/'
    filename: '[name].bundle.js'

  module:
    loaders: [
      {test: /\.coffee$/, loader: 'coffee-loader'}
      {test: /\.styl$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!stylus-loader")}
      {test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader")}
      {test: /.*\.(gif|png|jpg|jpeg|svg)$/, loaders: ['file?name=img/[hash:4].[ext]', 'image-webpack?optimizationLevel=7&interlaced=false']}
      {test: /.*\.(eot|woff2|woff|ttf)/, loader: 'file?font/[hash:8].[ext]'}
    ]

  resolve:
    alias:
      jquery: './jquery.coffee'
    extensions: ['', '.coffee', '.js', '.styl', '.css']

  plugins: [
    new webpack.optimize.UglifyJsPlugin()
    new ExtractTextPlugin("styles.css")
    new webpack.optimize.CommonsChunkPlugin name: 'vendor', minChunks: Infinity
  ]