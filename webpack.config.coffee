path = require 'path'
webpack = require 'webpack'
fs = require 'fs'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
isProduction = process.env.NODE_ENV == 'production'

vendors = [
  "lodash"
  "jquery"
  "classnames"
  "jquery.scrollto"
  "jed"
  "immutable"
  "react"
  "react-bootstrap"
  "react-dom"
  "bazooka"

  # Legacy
  "jquery.jqmodal"
  "jquery.ui"
  "jquery.form"
  "jquery.markitup"
  "jquery.jcrop"
  "jquery.file"
]

module.exports =
  context: path.join __dirname, 'frontend'
  cache: true
  devtool: "#source-map"

  entry:
    main: "./main"
    comments: "./comments"
    topics: "./topics"
    blogs: "./blogs"
    vendor: vendors

  output:
    path: path.join __dirname, 'static', '[hash]'
    publicPath: "./"
    filename: '[name].bundle.js'

  module:
    loaders: [
      {test: /\.jsx?$/, loader: 'babel-loader', exclude: /node_modules/, query: {presets: ['es2015', 'react']}}
      {test: /\.coffee$/, loader: 'coffee-loader'}
      {test: /\.styl$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!stylus-loader")}
      {test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader")}
      {test: /\.po$/, loader: 'json!po?format=jed1.x'}
      {
        test: /.*\.(gif|png|jpg|jpeg|svg)$/,
        loaders: Array::concat(
          if isProduction then ['file?name=img/[hash:4].[ext]'] else ['file?name=img/[name].[ext]']
          if isProduction then ['image-webpack?optimizationLevel=7&interlaced=false'] else []
        )
      }
    ]

  resolve:
    extensions: ['', '.coffee', '.js', '.styl', '.css']
    modulesDirectories: ['node_modules', 'scripts', 'locale']
    root: [
      process.env.NODE_PATH
      path.resolve(path.join(__dirname, 'frontend', 'vendor'))
    ]

  resolveLoader:
    root: process.env.NODE_PATH

  plugins: Array::concat(
    if isProduction then [
      new webpack.optimize.UglifyJsPlugin()
    ] else []
    [
      new ExtractTextPlugin "[name].css"
      new webpack.optimize.DedupePlugin()
      new webpack.optimize.CommonsChunkPlugin name: 'vendor', minChunks: Infinity
      () ->
        @plugin("done", (stats) ->
          fs.writeFileSync(
            path.join(__dirname, "config", "frontend.version"),
            stats.hash
          )
        )
    ]
  )