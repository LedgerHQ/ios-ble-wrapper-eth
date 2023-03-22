//
//  File.swift
//  
//
//  Created by Stephen Chase on 22/03/2023.
//

import Foundation

public struct ResolutionConfig: Decodable {
    public let erc20Tokens: Bool
    public let nfts: Bool
    public let externalPlugin: Bool
    
    public init(erc20Tokens: Bool, nfts: Bool, externalPlugin: Bool) {
        self.erc20Tokens = erc20Tokens
        self.nfts = nfts
        self.externalPlugin = externalPlugin
    }
    
    func toDictionary() -> [String: Any] {
        return ["erc20Tokens": erc20Tokens, "nfts": nfts, "externalPlugin": externalPlugin];
    }
}
