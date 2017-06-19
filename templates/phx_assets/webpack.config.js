const Webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const path = require("path");

const rule_js = {
  test: /\.js$/,
  exclude: /node_modules/,
  loader: "babel-loader"
};

const resolve = {
  extensions: [".js", ".less"],
  modules: [
    path.join(__dirname, "js"),
    "node_modules"
  ],
  alias: {
    containers: path.resolve(__dirname, "js/containers/"),
    components: path.resolve(__dirname, "js/components/"),
    reducers: path.resolve(__dirname, "js/reducers/"),
    routes: path.resolve(__dirname, "js/routes/"),
    store: path.resolve(__dirname, "js/store/")
  }
}

module.exports = [{
  // Client
  entry: [
    path.join(__dirname, "js/index.js"),
    path.join(__dirname, "styles/index.less")
  ],
  output: {
    path: path.join(__dirname, "../priv/static"),
    filename: "js/app.js",
    publicPath: "/"
  },
  module: {
    rules: [
      rule_js,
      {
        test: /\.less$/,
        use: ExtractTextPlugin.extract({
          fallback: "style-loader",
          use: ["css-loader", "less-loader"]
        })
      }
    ]
  },
  resolve: resolve,
  plugins: [
    new ExtractTextPlugin({
      filename: "css/app.css",
      allChunks: true
    }),
    new CopyPlugin([{from: path.join(__dirname, "static")}])
  ]
}, {
  // Server
  entry: {
    component: path.join(__dirname, "js/containers/index.js")
  },
  output: {
    path: path.join(__dirname, "../priv/static/server/js"),
    filename: "app.js",
    library: "dl",
    libraryTarget: "commonjs2"
  },
  module: {
    rules: [
      rule_js
    ]
  },
  resolve: resolve
}];

