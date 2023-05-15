const webpack = require("webpack");
const path = require("path");

module.exports = {
  mode: "production",
  // optimization: {
  //   minimize: false
  // },
  output: {
    filename: "bundle.js",
    library: "TransportModule",
    path: path.resolve(__dirname, "./"),
  },
  resolve: {
    fallback: {
      buffer: require.resolve("buffer/"),
    },
  },
  plugins: [
    new webpack.ProvidePlugin({
      Buffer: ["buffer", "Buffer"],
    })
  ],
};
