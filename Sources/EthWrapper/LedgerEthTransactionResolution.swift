//
//  LedgerEthTransactionResolution.swift
//  
//
//  Created by Harrison Friia on 11/16/22.
//

import Foundation

public struct ExternalPluginData: Decodable, Equatable {
    public let payload: String
    public let signature: String
}

public struct LedgerEthTransactionResolution: Decodable {
    public let erc20Tokens: [String]
    public let nfts: [String]
    public let externalPlugin: [ExternalPluginData]
    public let plugin: [String]
    
    public init(erc20Tokens: [String], nfts: [String], externalPlugin: [ExternalPluginData], plugin: [String]) {
        self.erc20Tokens = erc20Tokens
        self.nfts = nfts
        self.externalPlugin = externalPlugin
        self.plugin = plugin
    }
    
    func toDictionary() -> [String: Any] {
        let externalPluginDictionary = externalPlugin.map({ ["payload": $0.payload, "signature": $0.signature] })
        return ["erc20Tokens": erc20Tokens, "nfts": nfts, "externalPlugin": externalPluginDictionary, "plugin": plugin];
    }
}
