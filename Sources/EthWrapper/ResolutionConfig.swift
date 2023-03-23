//
//  File.swift
//  
//
//  Created by Stephen Chase on 22/03/2023.
//

import Foundation

public struct ResolutionConfig: Decodable {
    public let erc20: Bool
    public let externalPlugins: Bool
    public let nft: Bool
    
    public init(erc20: Bool, externalPlugins: Bool, nft: Bool) {
        self.erc20 = erc20
        self.externalPlugins = externalPlugins
        self.nft = nft
    }
    
    func toDictionary() -> [String: Any] {
        return ["erc20": erc20, "externalPlugins": externalPlugins, "nft": nft];
    }
}
