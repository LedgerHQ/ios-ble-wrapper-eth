# EthWrapper

This is the Swift Package to use the JavaScript Eth app binding in a native way. It consist of a `bundle.js` which is the compiled app binding (plus a wrapper) and convenience methods.

Whenever there's a change in the Eth app binding or the wrapper, `bundle.js` has to be regenerated using [browserify](https://browserify.org/).

### How to generate `bundle.js`

1. Clone the [monorepo](https://github.com/ledgerhq/ledger-live) and compile the libraries using `pnpm build:libs`
2. Run the following commands in `Sources/EthWrapper/JavaScript`:

```
pnpm i
pnpm build --entry "<path_to_monorepo>/ledger-live/libs/ledgerjs/packages/swift-bridge-hw-app-eth/lib/Wrapper.js"
```
For example:

```
cd ~
git clone https://github.com/LedgerHQ/ledger-live.git
cd ledger-live
pnpm i && pnpm build:libs

cd ~
git clone https://github.com/LedgerHQ/ios-ble-wrapper-eth.git
cd ios-ble-wrapper-eth/Sources/EthWrapper/JavaScript
pnpm i
pnpm build --entry "~/ledger-live/libs/ledgerjs/packages/swift-bridge-hw-app-eth/lib/Wrapper.js"
```
