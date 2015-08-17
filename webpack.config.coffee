path = require 'path'
webpack = require 'webpack'
{merge, keys} = require 'lodash'
pkginfo = require "./package.json"
ExtractTextPlugin = require 'extract-text-webpack-plugin'

aliases =
  "jquery.jqmodal": path.join __dirname, 'frontend', 'vendor', 'jquery.jqmodal.js'
  "jquery.ui": path.join __dirname, 'frontend', 'vendor', 'jquery.ui.js'
  "jquery.form": path.join __dirname, 'frontend', 'vendor', 'jquery.form.js'

module.exports =
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    vendor: keys(aliases).concat keys(pkginfo.dependencies)

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
    ]

  resolve:
    alias: aliases
    extensions: ['', '.coffee', '.js', '.styl', '.css']
    modulesDirectories: ['node_modules', 'scripts']

  plugins: [
    new webpack.optimize.UglifyJsPlugin()
    new ExtractTextPlugin("styles.css")
    new webpack.optimize.CommonsChunkPlugin name: 'vendor', minChunks: Infinity
  ]