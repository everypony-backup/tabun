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
  "react-bootstrap"
  "bazooka"

  # Legacy
  "jquery.jqmodal"
  "jquery.ui"
  "jquery.form"
  "jquery.markitup"
  "jquery.jcrop"
  "jquery.file"
]
if isProduction
  vendors.push("react", "react-dom")
else
  vendors.push("react-lite")

cfg =
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    comments: "./comments"
    editor: "./editor"
    blogs: "./blogs"
    vendor: vendors

  output:
    path: path.join __dirname, 'static', '[hash]'
    publicPath: "./"
    filename: '[name].bundle.js'

  module:
    loaders: [
      {test: /\.jsx?$/, loader: 'babel-loader', exclude: /node_modules/, query: {presets: ['es2015', 'react']}, compact: true}
      {test: /\.coffee$/, loader: 'coffee-loader'}
      {test: /\.styl$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!stylus-loader")}
      {test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader")}
      {test: /\.po$/, loader: 'json!po?format=jed1.x'}
      {
        test: /.*\.(gif|png|jpg|jpeg|svg)$/,
        loaders: (if isProduction then ['file?name=img/[hash:4].[ext]'] else ['file?name=img/[name].[ext]'])
      }
    ]

  resolve:
    extensions: ['', '.coffee', '.js', '.styl', '.css']
    modulesDirectories: ['node_modules', 'scripts']
    root: [
      process.env.NODE_PATH
      path.resolve(path.join(__dirname, 'frontend', 'vendor'))
      path.resolve(path.join(__dirname, 'templates', 'skin', 'synio'))
    ]

  resolveLoader:
    root: process.env.NODE_PATH

  plugins: [
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

if isProduction
  cfg.resolve.alias =
    'react': 'react-lite'
    'react-dom': 'react-lite'

  cfg.plugins.push(new webpack.optimize.UglifyJsPlugin())
else
  cfg.devtool = "#source-map"

module.exports = cfg