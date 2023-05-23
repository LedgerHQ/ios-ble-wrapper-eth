import Foundation
import JavaScriptCore


class Console {
    static func registerInto(jsContext: JSContext) {
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("JavaScript console.log: \(message)")
        }
        
        let consoleError: @convention(block) (String) -> Void = { message in
            print("JavaScript console.error: \(message)")
        }
        
        jsContext.objectForKeyedSubscript("console").setObject(consoleLog, forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)?)
        
        jsContext.objectForKeyedSubscript("console").setObject(consoleError, forKeyedSubscript: "error" as (NSCopying & NSObjectProtocol)?)
    }
}



