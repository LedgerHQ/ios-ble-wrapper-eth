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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// `create` connects automatically to the first discovered device so have your device ready before launching this demo
        BleTransport.shared.create {
            print("Device disconnected")
        } success: { connectedPeripheral in
            print("Connected to peripheral with name: \(connectedPeripheral.name)")
            let eth = EthereumWrapper()
            eth.getAppConfiguration { response in
                print("Response received: \(response)")
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

