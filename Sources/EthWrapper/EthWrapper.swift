//
//  EthereumWrapper.swift
//
//  Created by Dante Puglisi on 7/4/22.
//

import Foundation
import JavaScriptCore
import BleWrapper
import BleTransport
import os

public class EthWrapper: BleWrapper {
    enum Method: String {
        case getAppConfiguration = "getAppConfiguration"
        case getAddress = "getAddress"
        case signTransaction = "signTransaction"
        case signPersonalMessage = "signPersonalMessage"
        case signEIP712HashedMessage = "signEIP712HashedMessage"
    }
    
    lazy var jsContext: JSContext = {
        let jsContext = JSContext()
        guard let jsContext = jsContext else { fatalError("jsContext is nil") }
        
        guard let commonJSPath = Bundle.module.path(forResource: "bundle", ofType: "js") else {
            fatalError("Unable to read resource files.")
        }
        
        do {
            let common = try String(contentsOfFile: commonJSPath, encoding: String.Encoding.utf8)
            _ = jsContext.evaluateScript(common)
        } catch (let error) {
            fatalError("Error while processing script file: \(error)")
        }
        
        return jsContext
    }()
    
    var ethInstance: JSValue?
    
    public override init() {
        super.init()
        injectTransportJS()
        loadInstance()
    }
    
    fileprivate func injectTransportJS() {
        jsContext.setObject(TransportJS.self, forKeyedSubscript: "SwiftTransport" as (NSCopying & NSObjectProtocol))
        
        jsContext.exceptionHandler = { [weak self] _, error in
            self?.log("Caught exception:", error as Any)
        }
        
        jsContext.setObject(
            {()->@convention(block) (JSValue)->Void in { print($0) }}(),
            forKeyedSubscript: "print" as NSString
        )
    }
    
    fileprivate func loadInstance() {
        guard let module = jsContext.objectForKeyedSubscript("TransportModule") else { return }
        guard let transportModule = module.objectForKeyedSubscript("TransportBLEiOS") else { return }
        guard let transportInstance = transportModule.construct(withArguments: []) else { return }
        guard let ethModule = module.objectForKeyedSubscript("Eth") else { return }
        ethInstance = ethModule.construct(withArguments: [transportInstance])
    }
    
    // MARK: - Async methods
    public func openApp() async throws {
        return try await super.openApp("Ethereum")
    }
    
    public func openAppIfNeeded() async throws {
        return try await super.openAppIfNeeded("Ethereum")
    }
    
    public func getAppConfiguration() async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            getAppConfiguration { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: BleTransportError.lowerLevelError(description: error))
            }
        }
    }
    
    public func getAddress(path: String, boolDisplay: Bool, boolChaincode: Bool) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            getAddress(path: path, boolDisplay: boolDisplay, boolChaincode: boolChaincode) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: BleTransportError.lowerLevelError(description: error))
            }
        }
    }
    
    public func signTransaction(path: String, rawTxHex: String) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signTransaction(path: path, rawTxHex: rawTxHex) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: BleTransportError.lowerLevelError(description: error))
            }
        }
    }
    
    public func signPersonalMessage(path: String, messageHex: String) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signPersonalMessage(path: path, messageHex: messageHex) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: BleTransportError.lowerLevelError(description: error))
            }
        }
    }
    
    public func signEIP712HashedMessage(path: String, domainSeparatorHex: String, hashStructMessageHex: String) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signEIP712HashedMessage(path: path, domainSeparatorHex: domainSeparatorHex, hashStructMessageHex: hashStructMessageHex) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: BleTransportError.lowerLevelError(description: error))
            }
        }
    }
    
    // MARK: - Completion methods
    public func openApp(success: @escaping EmptyResponse, failure: @escaping ErrorResponse) {
        super.openApp("Ethereum", success: success, failure: failure)
    }
    
    public func openAppIfNeeded(completion: @escaping (Result<Void, BleTransportError>) -> Void) {
        super.openAppIfNeeded("Ethereum", completion: completion)
    }
    
    public func getAppConfiguration(success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        invokeMethod(.getAppConfiguration, arguments: [], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    public func getAddress(path: String, boolDisplay: Bool, boolChaincode: Bool, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        invokeMethod(.getAddress, arguments: [path, boolDisplay, boolChaincode], success: { resolve in
            if let dict = resolve.toDictionary() as? [String: String] {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    public func signTransaction(path: String, rawTxHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        invokeMethod(.signTransaction, arguments: [path, rawTxHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    public func signPersonalMessage(path: String, messageHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        invokeMethod(.signPersonalMessage, arguments: [path, messageHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    public func signEIP712HashedMessage(path: String, domainSeparatorHex: String, hashStructMessageHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        invokeMethod(.signEIP712HashedMessage, arguments: [path, domainSeparatorHex, hashStructMessageHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    // MARK: - Private methods
    fileprivate func invokeMethod(_ method: Method, arguments: [Any], success: @escaping JSValueResponse, failure: @escaping StringResponse) {
        guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync(method.rawValue, withArguments: arguments, completionHandler: { resolve, reject in
            if let resolve = resolve {
                success(resolve)
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })
    }
}
