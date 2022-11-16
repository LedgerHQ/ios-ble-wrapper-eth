//
//  LedgerEthTransactionResolutionTests.swift
//  
//
//  Created by Harrison Friia on 11/16/22.
//

import XCTest
@testable import EthWrapper

final class LedgerEthTransactionResolutionTests: XCTestCase {
    
    func testDecodeFromJSON() throws {
        let json = """
        {
            "erc20Tokens": [],
            "nfts": [],
            "externalPlugin": [{
                "payload": "085061726173",
                "signature": "30450221008"
            }],
            "plugin": []
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let result: LedgerEthTransactionResolution = try decoder.decode(LedgerEthTransactionResolution.self, from: json)
        
        XCTAssertEqual(result.erc20Tokens, [])
        XCTAssertEqual(result.nfts, [])
        XCTAssertEqual(result.externalPlugin, [ExternalPluginData(payload: "085061726173", signature: "30450221008")])
        XCTAssertEqual(result.plugin, [])
    }
    
    func testConvertToDictionary() throws {
        let json = """
        {
            "erc20Tokens": [],
            "nfts": [],
            "externalPlugin": [{
                "payload": "085061726173",
                "signature": "30450221008"
            }],
            "plugin": []
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let result: LedgerEthTransactionResolution = try decoder.decode(LedgerEthTransactionResolution.self, from: json)
        
        let dictionary = result.toDictionary()

        XCTAssertEqual(dictionary["erc20Tokens"] as? [String], [])
        XCTAssertEqual(dictionary["nfts"] as? [String], [])
        XCTAssertEqual(dictionary["externalPlugin"] as? [[String: String]], [["payload": "085061726173", "signature": "30450221008"]])
        XCTAssertEqual(dictionary["plugin"] as? [String], [])
    }
    
}
