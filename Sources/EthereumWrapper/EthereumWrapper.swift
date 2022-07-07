//
//  EthereumWrapper.swift
//  EthereumWrapper
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
    
    public init() {
        injectTransportJS()
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
    
    public func getAppConfiguration(success: @escaping (([AnyHashable: Any])->()), failure: @escaping ((String)->())) {
        guard let module = jsContext.objectForKeyedSubscript("TransportModule") else { return }
        guard let transportModule = module.objectForKeyedSubscript("TransportBLEiOS") else { return }
        guard let transportInstance = transportModule.construct(withArguments: []) else { return }
        guard let ethModule = module.objectForKeyedSubscript("Eth") else { return }
        guard let ethInstance = ethModule.construct(withArguments: [transportInstance]) else { return }
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
}

enum PubKeyDisplayMode: Int {
    case long = 0
    case short = 1
}

public struct AppConfig {
    let blindSigningEnabled: Bool
    let pubKeyDisplayMode: PubKeyDisplayMode
    let version: String
}
