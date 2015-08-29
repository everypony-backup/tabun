path = require 'path'
webpack = require 'webpack'
{keys} = require 'lodash'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
StatsPlugin = require 'stats-webpack-plugin'
isProduction = process.env.NODE_ENV == 'production';


vendors = [
  "lodash"
  "jquery"
  "classnames"
  "jquery.scrollto"
  "jed"
]

aliases =
  "jquery.jqmodal": path.join __dirname, 'frontend', 'vendor', 'jquery.jqmodal.js'
  "jquery.ui": path.join __dirname, 'frontend', 'vendor', 'jquery.ui.js'
  "jquery.form": path.join __dirname, 'frontend', 'vendor', 'jquery.form.js'
  "jquery.markitup": path.join __dirname, 'frontend', 'vendor', 'jquery.markitup.js'
  "jquery.jcrop": path.join __dirname, 'frontend', 'vendor', 'jquery.jcrop.js'
  "jquery.file": path.join __dirname, 'frontend', 'vendor', 'jquery.file.js'

module.exports =
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    comments: "./comments"
    topics: "./topics"
    vendor: Array::concat keys(aliases), vendors

  output:
    path: path.join __dirname, 'static'
    publicPath: '/static/'
    filename: if isProduction then '[name].[hash].bundle.js' else '[name].trunk.bundle.js'

  module:
    loaders: [
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
    alias: aliases
    extensions: ['', '.coffee', '.js', '.styl', '.css']
    modulesDirectories: ['node_modules', 'scripts', 'locale']

  plugins: Array::concat(
    if isProduction then [
      new webpack.optimize.UglifyJsPlugin()
      new StatsPlugin 'stats.json', modules: false, chunks: false, assets: false, version: false, errorDetails: false
    ] else []
    [
      new ExtractTextPlugin if isProduction then "styles.[hash].css" else "styles.trunk.css"
      new webpack.optimize.CommonsChunkPlugin name: 'vendor', minChunks: Infinity
    ]
  )