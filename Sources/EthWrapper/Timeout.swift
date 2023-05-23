import Foundation
import JavaScriptCore

let TimeoutSharedInstance = Timeout()

@objc protocol TimeoutExport : JSExport {

    func setTimeout(_ callback : JSValue,_ ms : Double) -> String

    func clearTimeout(_ identifier: String)

    func setInterval(_ callback : JSValue,_ ms : Double) -> String

}

@objc class Timeout: NSObject, TimeoutExport {
    var timers = [String: Timer]()

    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "Timeout") {
        jsContext.setObject(TimeoutSharedInstance,
                            forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript(
            "function setTimeout(callback, ms) {" +
            "    return Timeout.setTimeout(callback, ms)" +
            "}" +
            "function clearTimeout(indentifier) {" +
            "    Timeout.clearTimeout(indentifier)" +
            "}" +
            "function setInterval(callback, ms) {" +
            "    return Timeout.setInterval(callback, ms)" +
            "}"
        )
    }

    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)

        timer?.invalidate()
    }


    func setInterval(_ callback: JSValue,_ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }

    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }

    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms / 1000.0
        let uuid = NSUUID().uuidString

        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.callJsCallback),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })


        return uuid
    }

    @objc func callJsCallback(_ timer: Timer) {
        let callback = (timer.userInfo as! JSValue)

        callback.call(withArguments: nil)
    }
}
