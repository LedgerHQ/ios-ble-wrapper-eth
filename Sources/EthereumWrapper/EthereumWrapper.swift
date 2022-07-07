//
//  EthereumWrapper.swift
//
//  Created by Dante Puglisi on 7/4/22.
//

import Foundation
import JavaScriptCore

public class EthereumWrapper {
    lazy var jsContext: JSContext = {
        let jsContext = JSContext()
        guard let jsContext = jsContext else { fatalError() }
        
        guard let
                commonJSPath = Bundle.module.path(forResource: "bundle", ofType: "js") else {
            print("Unable to read resource files.")
            fatalError()
        }
        
        do {
            let common = try String(contentsOfFile: commonJSPath, encoding: String.Encoding.utf8)
            _ = jsContext.evaluateScript(common)
        } catch (let error) {
            print("Error while processing script file: \(error)")
            fatalError()
        }
        
        return jsContext
    }()
    
    var ethInstance: JSValue?
    
    public init() {
        injectTransportJS()
        loadInstance()
    }
    
    fileprivate func injectTransportJS() {
        jsContext.setObject(TransportJS.self, forKeyedSubscript: "SwiftTransport" as (NSCopying & NSObjectProtocol))
        
        jsContext.exceptionHandler = { _, error in
            print("Caught exception:", error as Any)
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
    
    public func getAppConfiguration(success: @escaping (([AnyHashable: Any])->()), failure: @escaping ((String)->())) {
        guard let ethInstance = ethInstance else { failure("Instance not initialized"); return }
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
        })
    }
    
    public func signTransaction(path: String, rawTxHex: String, success: @escaping (([AnyHashable: Any])->()), failure: @escaping ((String)->())) {
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
}
