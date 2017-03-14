path = require 'path'
webpack = require 'webpack'
poststylus = require 'poststylus'
postUse = require "postcss-use"
fs = require 'fs'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
isProduction = process.env.NODE_ENV == 'production'
isTrunk = process.env.NODE_ENV == 'trunk'

vendors = [
  "bazooka"
  "classnames"
  "immutable"
  "jed"
  "jquery"
  "jquery.scrollto"
  "xhr"
  "lodash"

  # Legacy
  "jquery.jqmodal"
  "jquery.ui"
  "jquery.form"
  "jquery.markitup"
]
if isProduction
  vendors.push("react-lite")
else
  vendors.push("react", "react-dom")

cfg =
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    comments: "./comments"
    editor: "./editor"
    blogs: "./blogs"
    search: "./search"
    profile: "./profile"
    vendor: vendors

  output:
    path: path.join __dirname, 'static', (if isProduction or isTrunk then '[hash]' else 'ephemeral')
    publicPath: "./"
    filename: '[name].bundle.js'

  module:
    loaders: [
      {test: /\.jsx?$/, loader: 'babel-loader', exclude: /node_modules/, compact: true}
      {test: /\.coffee$/, loader: 'coffee-loader'}
      {test: /\.styl$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!stylus-loader")}
      {test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader")}
      {test: /\.json$/, loader: 'json'}
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
      path.resolve(__dirname)
      path.resolve(path.join(__dirname, 'frontend', 'vendor'))
      path.resolve(path.join(__dirname, 'templates', 'skin', 'synio'))
    ]

  resolveLoader:
    root: process.env.NODE_PATH

  plugins: [
      new ExtractTextPlugin "[name].css"
      new webpack.optimize.DedupePlugin()
      new webpack.optimize.CommonsChunkPlugin name: 'vendor', minChunks: Infinity
    ]
  stylus:
    preferPathResolver: 'webpack'
    use: [
      require('bootstrap-styl')()
      poststylus([ postUse({ modules: ['postcss-selector-namespace']}) ])
    ]
    compress: true

if isProduction
  cfg.resolve.alias =
    'react': 'react-lite'
    'react-dom': 'react-lite'

  cfg.plugins.push(new webpack.optimize.UglifyJsPlugin())

if isProduction or isTrunk
  cfg.plugins.push(() ->
    @plugin("done", (stats) ->
      fs.writeFileSync(
        path.join(__dirname, "frontend.version"),
        stats.hash
      )
    ))

if not (isProduction or isTrunk)
  cfg.devtool = "#source-map"

module.exports = cfg