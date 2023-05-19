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
        case clearSignTransaction = "clearSignTransaction"
    }
    
    lazy var jsContext: JSContext = {
        let jsContext = JSContext()
        guard let jsContext = jsContext else { fatalError("jsContext is nil") }
        
        // Add a 'console' object with a 'log' and 'error' function into the jsContext
        Console.registerInto(jsContext: jsContext)
        
        // Add 'setTimeout'-like functions into the jsContext
        Timeout.registerInto(jsContext: jsContext)
        
        // Add XHR Requests into the jsContext
        XMLHttpRequest.registerInto(jsContext: jsContext)
        
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
        guard let transportModule = module.objectForKeyedSubscript("TransportBLESwift") else { return }
        guard let transportInstance = transportModule.construct(withArguments: []) else { return }
        guard let ethModule = module.objectForKeyedSubscript("Eth") else { return }
        ethInstance = ethModule.construct(withArguments: [transportInstance])
    }
    
    // MARK: - Completion methods
    public func openAppIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        super.openAppIfNeeded("Ethereum", completion: completion)
    }
    
    public func getAppConfiguration(success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        invokeMethod(.getAppConfiguration, arguments: [], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "getAppConfiguration -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    public func getAddress(path: String, boolDisplay: Bool, boolChaincode: Bool, success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        invokeMethod(.getAddress, arguments: [path, boolDisplay, boolChaincode], success: { resolve in
            if let dict = resolve.toDictionary() as? [String: String] {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "getAddress -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    public func signTransaction(path: String, rawTxHex: String, resolution: LedgerEthTransactionResolution?, success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        var arguments: [Any] = [path, rawTxHex]
        if let resolution = resolution {
            arguments.append(resolution.toDictionary())
        }
        invokeMethod(.signTransaction, arguments: arguments, success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "signTransaction -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    public func signTransaction(path: String, rawTxHex: String, resolutionConfig: ResolutionConfig?, success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        var arguments: [Any] = [path, rawTxHex]
        if let resolutionConfig = resolutionConfig {
            arguments.append(resolutionConfig.toDictionary())
        }
        invokeMethod(.clearSignTransaction, arguments: arguments, success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "clearSignTransaction -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    public func signPersonalMessage(path: String, messageHex: String, success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        invokeMethod(.signPersonalMessage, arguments: [path, messageHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "signPersonalMessage -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    public func signEIP712HashedMessage(path: String, domainSeparatorHex: String, hashStructMessageHex: String, success: @escaping DictionaryResponse, failure: @escaping ErrorResponse) {
        invokeMethod(.signEIP712HashedMessage, arguments: [path, domainSeparatorHex, hashStructMessageHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure(BleTransportError.lowerLevelError(description: "signEIP712HashedMessage -> resolved but couldn't parse"))
            }
        }, failure: failure)
    }
    
    // MARK: - Private methods
    fileprivate func invokeMethod(_ method: Method, arguments: [Any], success: @escaping JSValueResponse, failure: @escaping ErrorResponse) {
        guard let ethInstance = ethInstance else { failure(BleTransportError.lowerLevelError(description: "invokeMethod -> instance not initialized")); return }
        ethInstance.invokeMethodAsync(method.rawValue, withArguments: arguments, completionHandler: { [weak self] resolve, reject in
            guard let self = self else { failure(BleTransportError.lowerLevelError(description: "invokeMethod -> self is nil")); return }
            if let resolve = resolve {
                success(resolve)
            } else if let reject = reject {
                failure(self.jsValueAsError(reject))
            }
        })
    }
}

/// Async implementations
extension EthWrapper {
    public func openAppIfNeeded() async throws {
        return try await super.openAppIfNeeded("Ethereum")
    }
    
    public func getAppConfiguration() async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            getAppConfiguration { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func getAddress(path: String, boolDisplay: Bool, boolChaincode: Bool) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            getAddress(path: path, boolDisplay: boolDisplay, boolChaincode: boolChaincode) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func signTransaction(path: String, rawTxHex: String, resolution: LedgerEthTransactionResolution?) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signTransaction(path: path, rawTxHex: rawTxHex, resolution: resolution) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func signPersonalMessage(path: String, messageHex: String) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signPersonalMessage(path: path, messageHex: messageHex) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func signEIP712HashedMessage(path: String, domainSeparatorHex: String, hashStructMessageHex: String) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signEIP712HashedMessage(path: path, domainSeparatorHex: domainSeparatorHex, hashStructMessageHex: hashStructMessageHex) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func signTransaction(path: String, rawTxHex: String, resolutionConfig: ResolutionConfig?) async throws -> [AnyHashable: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            signTransaction(path: path, rawTxHex: rawTxHex, resolutionConfig: resolutionConfig) { response in
                continuation.resume(returning: response)
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
