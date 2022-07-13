//
//  ViewController.swift
//  EthereumWrapperDemo
//
//  Created by Dante Puglisi on 7/6/22.
//

import UIKit
import EthereumWrapper
import BleTransport

class ViewController: UIViewController {

    let DERIVATION_PATH_ETH = "44'/60'/0'/0/0"
    let RAW_TX_HEX_TEST = "02f90115010384773594008518abb54a008302ceed94def171fe48cf0115b1d80b88dc8eab59176fee5787084701707a11e7b8e4b2f1e6db000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000084701707a11e700000000000000000000000000000000000000000000000029a2241af62c0000000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001000000000000000000004de4bf58a4077c71b5699bd19287eb76beaba5361bbfc0"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// `create` connects automatically to the first discovered device so have your device ready before launching this demo
        BleTransport.shared.create {
            print("Device disconnected")
        } success: { connectedPeripheral in
            print("Connected to peripheral with name: \(connectedPeripheral.name)")
            let eth = EthereumWrapper()
            /*eth.getAppConfiguration { response in
                print("Response received: \(response)")
            } failure: { error in
                print(error)
            }*/
            /*eth.signTransaction(path: self.DERIVATION_PATH_ETH, rawTxHex: self.RAW_TX_HEX_TEST) { response in
                print(response)
            } failure: { error in
                print(error)
            }*/
            eth.getAddress(path: self.DERIVATION_PATH_ETH, boolDisplay: false, boolChaincode: false) { response in
                print(response)
            } failure: { error in
                print(error)
            }

        } failure: { error in
            if let error = error {
                print(error.description())
            } else {
                print("No error")
            }
        }
    }

}

