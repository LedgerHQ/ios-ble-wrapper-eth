//
//  DeviceManager.swift
//  EthereumWrapperDemo
//
//  Created by Harrison Friia on 6/30/23.
//

import BleTransport
import BleWrapper
import EthWrapper
import SwiftUI

class DeviceManager: ObservableObject {
    let eth = EthWrapper()
    let DERIVATION_PATH_ETH = "44'/60'/0'/0/0"
    let RAW_TX_HEX_TEST = "02f90108010180808094def171fe48cf0115b1d80b88dc8eab59176fee578609184e72a000b8e40b86a4c1000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000009184e72a000000000000000000000000000000000000000000000000000004340cbb4c03c9a000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001000000000000000000004de58faf958e36c6970497386118030e6297fff8d275c0"

    @Published var connectionLabel: String = "Connecting..."
    @Published var created: Bool = false

    weak var logManager: LogManager?

    init() {
        BleTransport.shared.bluetoothAvailabilityCallback { availability in
            self.logManager?.addToLog("BLE available: \(availability.description)")

            if !self.created, availability {
                self.created = true
                self.create()
            }
        }
    }

    func create() {
        logManager?.addToLog("Attempting to connect...")

        BleTransport.shared.create(scanDuration: 5.0) {
            self.logManager?.addToLog("Device disconnected")
        } success: { connectedPeripheral in
            self.connectionLabel = "Connected to \(connectedPeripheral.name)"
            self.logManager?.addToLog("Connected to peripheral with name: \(connectedPeripheral.name)")
        } failure: { error in
            self.logManager?.addToLog("Error connecting: \(error)")
        }
    }

    func signTransaction() {
        logManager?.addToLog("Signing a Transaction...")
        let resolutionConfig = ResolutionConfig(erc20: true, externalPlugins: true, nft: true)
        eth.signTransaction(path: DERIVATION_PATH_ETH, rawTxHex: RAW_TX_HEX_TEST, resolutionConfig: resolutionConfig) { response in
            guard let dict = response as? [String: AnyObject] else { fatalError("Can't parse") }
            self.logManager?.addToLog("\(dict)")
        } failure: { error in
            self.logManager?.addToLog("Error signing transaction: \(error)")
        }
    }

    func getAppConfiguration() {
        logManager?.addToLog("Getting app configuration...")
        eth.getAppConfiguration { response in
            guard let dict = response as? [String: AnyObject] else { fatalError("Can't parse") }
            self.logManager?.addToLog("\(dict)")
        } failure: { error in
            self.logManager?.addToLog("Error getting app configuration: \(error)")
        }
    }

    func getAddress() {
        logManager?.addToLog("Getting address...")
        eth.getAddress(path: DERIVATION_PATH_ETH, boolDisplay: false, boolChaincode: false) { response in
            self.logManager?.addToLog("\(response)")
        } failure: { error in
            self.logManager?.addToLog("Error getting address: \(error)")
        }
    }

    func openApp() {
        Task {
            self.logManager?.addToLog("Opening Ethereum...")
            do {
                try await eth.openAppIfNeeded()
                self.logManager?.addToLog("Opened Ethereum!")
            } catch {
                self.logManager?.addToLog("Error opening Ethereum: \(error)")
            }
        }
    }
}
