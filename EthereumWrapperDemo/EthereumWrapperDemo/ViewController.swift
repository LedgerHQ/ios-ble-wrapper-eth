//
//  ViewController.swift
//  EthereumWrapperDemo
//
//  Created by Dante Puglisi on 7/6/22.
//

import UIKit
import EthWrapper
import BleTransport
import BleWrapper

class ViewController: UIViewController {

    @IBOutlet weak var waitingForResponseLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var getAppConfigurationButton: UIButton!
    @IBOutlet weak var getAddressButton: UIButton!
    @IBOutlet weak var openAppButton: UIButton!
    
    let DERIVATION_PATH_ETH = "44'/60'/0'/0/0"
    let RAW_TX_HEX_TEST = "02f90108010180808094def171fe48cf0115b1d80b88dc8eab59176fee578609184e72a000b8e40b86a4c1000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000009184e72a000000000000000000000000000000000000000000000000000004340cbb4c03c9a000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001000000000000000000004de58faf958e36c6970497386118030e6297fff8d275c0"
    
    let eth = EthWrapper()
    
    var created = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        connectionLabel.text = "Connecting..."
        
        BleTransport.shared.bluetoothAvailabilityCallback { availability in
            if !self.created && availability {
                self.created = true
                self.create(success: nil, failure: nil)
            }
        }
    }
    
    func create(success: EmptyResponse?, failure: ErrorResponse?) {
        self.getAppConfigurationButton.isEnabled = false
        self.getAddressButton.isEnabled = false
        self.openAppButton.isEnabled = false
        
        BleTransport.shared.create(scanDuration: 5.0) {
            print("Device disconnected")
        } success: { connectedPeripheral in
            self.connectionLabel.text = "Connected to \(connectedPeripheral.name)"
            print("Connected to peripheral with name: \(connectedPeripheral.name)")
            self.getAppConfigurationButton.isEnabled = true
            self.getAddressButton.isEnabled = true
            self.openAppButton.isEnabled = true
            success?()
        } failure: { error in
            failure?(error)
        }
    }
    
    
    @IBAction func signTransaction(_ sender: Any) {
        waitingForResponseLabel.text = "Signing a Transaction..."
        let resolutionConfig = ResolutionConfig(erc20: true, externalPlugins: true, nft: true)
        eth.signTransaction(path:DERIVATION_PATH_ETH, rawTxHex: RAW_TX_HEX_TEST, resolutionConfig: resolutionConfig) { response in
            guard let dict = response as? [String: AnyObject] else { fatalError("Can't parse") }
            self.waitingForResponseLabel.text = "\(dict)"
        } failure: { error in
            self.waitingForResponseLabel.text = "ERROR: \(error)"
        }
    }
    
    @IBAction func getAppConfigurationButtonTapped(_ sender: Any) {
        waitingForResponseLabel.text = "Getting App Configuration..."
        eth.getAppConfiguration { response in
            guard let dict = response as? [String: AnyObject] else { fatalError("Can't parse") }
            self.waitingForResponseLabel.text = "\(dict)"
        } failure: { error in
            self.waitingForResponseLabel.text = "ERROR: \(error)"
        }
    }
    
    @IBAction func getAddressButtonTapped(_ sender: Any) {
        waitingForResponseLabel.text = "Getting Address..."
        eth.getAddress(path: DERIVATION_PATH_ETH, boolDisplay: false, boolChaincode: false) { response in
            self.waitingForResponseLabel.text = "\(response)"
        } failure: { error in
            self.waitingForResponseLabel.text = "ERROR: \(error)"
        }
    }
    
    @IBAction func openAppButtonTapped(_ sender: Any) {
        Task() {
            print("Will try opening Ethereum")
            do {
                try await eth.openAppIfNeeded()
                print("Opened Ethereum!")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
