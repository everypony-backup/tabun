import fs from 'fs';
import path from 'path';
import MiniCssExtractPlugin from 'mini-css-extract-plugin';
import CleanWebpackPlugin from 'clean-webpack-plugin';
import poststylus from 'poststylus';
import postUse from 'postcss-use';
import bootstrapStyl from 'bootstrap-styl';

const ENV = process.env.NODE_ENV || 'development';
const isDev = ENV === 'development';
const devPrefix = isDev ? 'dev' : '[hash]';
const outputPath = path.resolve(__dirname, 'static');
const nodePath = process.env.NODE_PATH || path.join(__dirname, 'node_modules');

class WriteVersionPlugin {
  constructor(filename, dev) {
    this.filename = filename;
    this.dev = dev;
  }

  apply = (compiler) => {
    compiler.plugin('done', stats => {
      if (!fs.existsSync(stats.compilation.compiler.outputPath)){
        fs.mkdirSync(stats.compilation.compiler.outputPath);
      }
      fs.writeFileSync(
        path.join(stats.compilation.compiler.outputPath, this.filename),
        this.dev ? 'dev' : stats.hash,
      );
    });
  }
}

const extractLoaderOptions = {
  publicPath: './'
};

const cssLoaderOptions = {
  modules: false,
  importLoaders: 1,
  url: true,
  sourceMap: true
};

const stylusLoaderOptions = {
  preferPathResolver: 'webpack',
  use: [
    bootstrapStyl(),
    poststylus([
      postUse({
        modules: ['postcss-selector-namespace']
      })
    ])
  ],
  compress: !isDev,
  sourceMap: true
};

const fileLoaderOptions = {
  name: `[name].${devPrefix}.[ext]`,
  publicPath: './'
};

const basePlugins = [
  new MiniCssExtractPlugin({
    filename: `[name].${devPrefix}.css`,
  }),
  new WriteVersionPlugin('frontend.version', isDev),
];

const plugins = isDev ? [
  new CleanWebpackPlugin(outputPath, {watch: true, beforeEmit: true}),
  ...basePlugins,
] : basePlugins;

module.exports = {
  mode: ENV,
  context: path.resolve(__dirname, 'frontend'),
  entry: {
    main: ['./main.coffee', './main.styl'],
    comments: './comments.coffee',
    editor: './editor.js',
    blogs: './blogs.js',
    search: ['./search.js', './search.styl'],
    profile: './profile.js'
  },

  output: {
    path: outputPath,
    publicPath: '/',
    filename: `[name].${devPrefix}.js`,
  },

  resolve: {
    extensions: ['.coffee', '.jsx', '.js', '.json'],
    modules: [
      nodePath,
      'node_modules',
      path.resolve(__dirname, 'frontend'),
      path.resolve(path.join(__dirname, 'frontend', 'vendor')),
      path.resolve(path.join(__dirname, 'templates', 'skin', 'synio')),
    ],
  },
  resolveLoader: {
    modules: [
      'node_modules',
      nodePath,
    ]
  },

  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: [
          { loader: 'babel-loader' },
        ],
      },
      {
        test: /\.coffee$/,
        exclude: /node_modules/,
        use: [
          { loader: 'babel-loader' },
          { loader: 'coffee-loader' },
        ],
      },
      {
        test: /\.css$/,
        use: [
          { loader: MiniCssExtractPlugin.loader, options: extractLoaderOptions },
          { loader: 'css-loader', options: cssLoaderOptions },
        ],
      },
      {
        test: /\.styl$/,
        use: [
          { loader: MiniCssExtractPlugin.loader, options: extractLoaderOptions },
          { loader: 'css-loader', options: cssLoaderOptions },
          { loader: 'stylus-loader', options: stylusLoaderOptions }
        ]
      },
      {
        test: /\.(png|jpe?g|jp2|gif|svg|ico|bmp|ttf|otf|woff2?|eot|txt)$/,
        use: [
          { loader: 'file-loader', options: fileLoaderOptions }
        ]
      }
    ],
  },
  plugins,
  stats: { colors: true },

  optimization: {
    minimize: !isDev,
    runtimeChunk: {
      name: 'vendor'
    },
    splitChunks: {
      cacheGroups: {
        vendor: {
          name: 'vendor',
          test: /\/(node_modules)|(vendor)\//,
          chunks: 'all'
        }
      }
    }
  },
  performance: {
    maxEntrypointSize: 2048000,
    maxAssetSize: 1024000
  },

  node: {
    global: true,
    process: false,
    Buffer: false,
    __filename: false,
    __dirname: false,
    setImmediate: false,
  },

  devtool: 'source-map',
};
