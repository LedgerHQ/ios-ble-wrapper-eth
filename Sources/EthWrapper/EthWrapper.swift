//
//  EthereumWrapper.swift
//
//  Created by Dante Puglisi on 7/4/22.
//

import Foundation
import JavaScriptCore
import BleWrapper
import os

public class EthWrapper: BleWrapper {
    
    public typealias DictionaryResponse = (([AnyHashable: Any])->())
    public typealias StringResponse = ((String)->())
    public typealias JSValueResponse = ((JSValue)->())
    
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
    
    public func getAppConfiguration(success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        /*guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync("getAppConfiguration", withArguments: [], completionHandler: { resolve, reject in
            if let resolve = resolve {
                if let dict = resolve.toDictionary() {
                    success(dict)
                } else {
                    failure("Resolved but couldn't parse")
                }
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })*/
        invokeMethod(.getAppConfiguration, arguments: [], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
    public func getAddress(path: String, boolDisplay: Bool, boolChaincode: Bool, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync("getAddress", withArguments: [path, boolDisplay, boolChaincode], completionHandler: { resolve, reject in
            if let resolve = resolve {
                if let dict = resolve.toDictionary() as? [String: String] {
                    success(dict)
                } else {
                    failure("Resolved but couldn't parse")
                }
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })
    }
    
    public func signTransaction(path: String, rawTxHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync("signTransaction", withArguments: [path, rawTxHex], completionHandler: { resolve, reject in
            if let resolve = resolve {
                if let dict = resolve.toDictionary() {
                    success(dict)
                } else {
                    failure("Resolved but couldn't parse")
                }
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })
    }
    
    public func signPersonalMessage(path: String, messageHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync("signPersonalMessage", withArguments: [path, messageHex], completionHandler: { resolve, reject in
            if let resolve = resolve {
                if let dict = resolve.toDictionary() {
                    success(dict)
                } else {
                    failure("Resolved but couldn't parse")
                }
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })
    }
    
    public func signEIP712HashedMessage(path: String, domainSeparatorHex: String, hashStructMessageHex: String, success: @escaping DictionaryResponse, failure: @escaping StringResponse) {
        /*guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
        ethInstance.invokeMethodAsync("signEIP712HashedMessage", withArguments: [path, domainSeparatorHex, hashStructMessageHex], completionHandler: { resolve, reject in
            if let resolve = resolve {
                if let dict = resolve.toDictionary() {
                    success(dict)
                } else {
                    failure("Resolved but couldn't parse")
                }
            } else if let reject = reject {
                failure("REJECTED. Value: \(reject)")
            }
        })*/
        invokeMethod(.signEIP712HashedMessage, arguments: [path, domainSeparatorHex, hashStructMessageHex], success: { resolve in
            if let dict = resolve.toDictionary() {
                success(dict)
            } else {
                failure("Resolved but couldn't parse")
            }
        }, failure: failure)
    }
    
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
