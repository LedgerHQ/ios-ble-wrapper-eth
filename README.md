# EthWrapper

This is the Swift Package to use the JavaScript Eth app binding in a native way. It consist of a `bundle.js` which is the compiled app binding (plus a wrapper) and convenience methods.

Whenever there's a change in the Eth app binding or the wrapper, `bundle.js` has to be regenerated using [browserify](https://browserify.org/).

### How to generate `bundle.js`

1. Clone the [monorepo](https://github.com/ledgerhq/ledger-live) and compile the libraries using `pnpm build:libs`
2. cd into `Sources/EthWrapper/JavaScript`
2. Use [webpack](https://webpack.js.org) to wrap everything needed for `JavaScriptCore` to run the binding and put it into the `JavaScript` folder inside the Package (should replace the current `bundle.js`) using the following command:

```
webpack --entry "<path_to_monorepo>/ledger-live/libs/ledgerjs/iOS-wrappers/ios-wrapper-eth/lib/Wrapper.js"
```
