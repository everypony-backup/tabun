path = require 'path'
webpack = require 'webpack'
poststylus = require 'poststylus'
postUse = require "postcss-use"
fs = require 'fs'
MiniCssExtractPlugin = require 'mini-css-extract-plugin'

isProduction = process.env.NODE_ENV == 'production'
isTrunk = process.env.NODE_ENV == 'trunk'
nodePath = process.env.NODE_PATH or path.join(__dirname, 'node_modules')

extractLoaderOptions =
  publicPath: './'

cssLoaderOptions =
  modules: false
  importLoaders: 1
  url: true
  sourceMap: true

stylusLoaderOptions =
  preferPathResolver: 'webpack'
  use: [
    require('bootstrap-styl')()
    poststylus([ postUse({ modules: ['postcss-selector-namespace']}) ])
  ]
  compress: isProduction
  sourceMap: true

fileLoaderOptions =
  name: if isProduction then 'img/[hash:4].[ext]' else 'img/[name].[ext]'
  publicPath: './'

cfg =
  mode: if isProduction then 'production' else 'none'
  context: path.join __dirname, 'frontend'
  cache: true

  entry:
    main: "./main"
    comments: "./comments"
    editor: "./editor"
    blogs: "./blogs"
    search: "./search"
    profile: "./profile"

  output:
    path: path.join __dirname, 'static', (if isProduction or isTrunk then '[hash]' else 'ephemeral')
    publicPath: "./"
    filename: '[name].bundle.js'

  module:
    rules: [
      {test: /\.jsx?$/, use: 'babel-loader', exclude: /node_modules/}
      {test: /\.coffee$/, use: ['babel-loader', 'coffee-loader']}
      {
        test: /\.css$/,
        use: [
          {loader: MiniCssExtractPlugin.loader, options: extractLoaderOptions}
          {loader: 'css-loader', options: cssLoaderOptions}
        ]
      }
      {
        test: /\.styl$/,
        use: [
          {loader: MiniCssExtractPlugin.loader, options: extractLoaderOptions}
          {loader: 'css-loader', options: cssLoaderOptions}
          {loader: 'stylus-loader', options: stylusLoaderOptions}
        ]
      }
      {
        test: /\.(png|jpe?g|jp2|gif|svg|ico|bmp|webp|webm|mp4|mkv|mp3|ogg|aac|ttf|otf|woff2?|eot|txt)$/,
        use: [
          {loader: 'file-loader', options: fileLoaderOptions},
        ],
      }
    ]

  resolve:
    extensions: ['.coffee', '.js', '.styl', '.css']
    modules: [
      nodePath
      path.resolve(path.join(__dirname, 'frontend', 'scripts'))
      path.resolve(path.join(__dirname, 'frontend', 'vendor'))
      path.resolve(path.join(__dirname, 'templates', 'skin', 'synio'))
    ]
    mainFiles: ['main', 'index']
    mainFields: ['main', 'module']

  resolveLoader:
    modules: [nodePath]

  plugins: [
    new MiniCssExtractPlugin { filename: '[name].css' }
  ]

  optimization:
    minimize: isProduction
    runtimeChunk:
      name: 'vendor'
    splitChunks:
      cacheGroups:
        vendor:
          name: 'vendor'
          test: /\/(node_modules)|(vendor)\//
          chunks: 'all'

if isProduction
  cfg.resolve.alias =
    'react': 'react-lite'
    'react-dom': 'react-lite'

if isProduction or isTrunk
  cfg.plugins.push(() ->
    @plugin("done", (stats) ->
      fs.writeFileSync(
        path.join(__dirname, "frontend.version"),
        stats.hash
      )
    ))

if not (isProduction or isTrunk)
  cfg.devtool = "source-map"

module.exports = cfg
