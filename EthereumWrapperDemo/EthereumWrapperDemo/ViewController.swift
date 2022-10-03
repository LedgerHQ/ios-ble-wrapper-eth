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
    let RAW_TX_HEX_TEST = "02f90115010384773594008518abb54a008302ceed94def171fe48cf0115b1d80b88dc8eab59176fee5787084701707a11e7b8e4b2f1e6db000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000084701707a11e700000000000000000000000000000000000000000000000029a2241af62c0000000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001000000000000000000004de4bf58a4077c71b5699bd19287eb76beaba5361bbfc0"
    
    let eth = EthWrapper()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        connectionLabel.text = "Connecting..."
        
        create(success: nil, failure: nil)
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
