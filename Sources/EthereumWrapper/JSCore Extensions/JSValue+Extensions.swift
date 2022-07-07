//
//  JSValue+Extensions.swift
//
//  Created by Connor Grady on 11/16/17.
//  Copyright © 2017 Connor Grady. All rights reserved.
//

import JavaScriptCore
import Foundation

public extension JSValue {
    
    convenience init(_ value: Any!, in context: JSContext!) {
        switch value {
        case let value as Bool:
            self.init(bool: value, in: context)
        case let value as Int32:
            self.init(int32: value, in: context)
        case let value as UInt32:
            self.init(uInt32: value, in: context)
        case let value as Double:
            self.init(double: value, in: context)
        case let value as CGRect:
            self.init(rect: value, in: context)
        case let value as CGSize:
            self.init(size: value, in: context)
        case let value as CGPoint:
            self.init(point: value, in: context)
        case let value as NSRange:
            self.init(range: value, in: context)
        case let value as Error:
            self.init(newErrorFromMessage: value.localizedDescription, in: context)
        case let value as NSObjectProtocol:
            self.init(object: value, in: context)
        default:
            self.init(undefinedIn: context)
        }
    }
    
    var isFunction: Bool {
        guard isObject else { return false }
        return JSObjectIsFunction(context.jsGlobalContextRef, jsValueRef)
    }
    
    @discardableResult
    func callAsync(withArguments arguments: [Any]!, completionHandler: @escaping (JSValue?, JSValue?) -> Void) -> JSValue! {
        var retVal = call(withArguments: arguments)!
        if retVal.isPromise {
            let fulfilledHandler: @convention(block) (JSValue?) -> Void = { value in
                completionHandler(value, nil)
            }
            let rejectedHandler: @convention(block) (JSValue?) -> Void = { error in
                completionHandler(nil, error)
            }
            retVal = retVal.invokeMethod("then", withArguments: [JSValue(object: fulfilledHandler, in: context) as Any, JSValue(object: rejectedHandler, in: context) as Any])
        } else {
            completionHandler(retVal, nil)
        }
        return retVal
    }
    
    @discardableResult
    func invokeMethodAsync(_ method: String!, withArguments arguments: [Any]!, completionHandler: @escaping (JSValue?, JSValue?) -> Void) -> JSValue! {
        var retVal = invokeMethod(method, withArguments: arguments)!
        if retVal.isPromise {
            let fulfilledHandler: @convention(block) (JSValue?) -> Void = { value in
                completionHandler(value, nil)
            }
            let rejectedHandler: @convention(block) (JSValue?/*Error*/) -> Void = { error in
                completionHandler(nil, error)
            }
            retVal = retVal.invokeMethod("then", withArguments: [JSValue(object: fulfilledHandler, in: context) as Any, JSValue(object: rejectedHandler, in: context) as Any])
        } else {
            completionHandler(retVal, nil)
        }
        return retVal
    }
    
}
