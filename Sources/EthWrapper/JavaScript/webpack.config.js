const webpack = require("webpack");
const path = require("path");

module.exports = {
  mode: "production",
  // Uncomment the following line to debug the bundle
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
    }),
  ],
};
