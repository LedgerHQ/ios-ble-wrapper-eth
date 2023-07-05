import Foundation
import JavaScriptCore

@objc protocol XMLHttpRequestExports: JSExport {
    var onreadystatechange: JSValue? { get set }
    var onerror: JSValue? { get set }
    var readyState: Int { get }
    var status: Int { get }
    var statusText: String? { get }
    var responseText: String? { get }

    init()
    func open(_ method: String, _ url: String)
    func send(_ data: String?)
}

@objc class XMLHttpRequest: NSObject, XMLHttpRequestExports {
    private var onreadystatechangeManaged: JSManagedValue?
    dynamic var onreadystatechange: JSValue? {
        get {
            onreadystatechangeManaged?.value
        }
        set {
            guard let newValue else {
                onreadystatechangeManaged = nil
                return
            }
            onreadystatechangeManaged = JSManagedValue(value: newValue, andOwner: self)
        }
    }

    private var onerrorManaged: JSManagedValue?
    dynamic var onerror: JSValue? {
        get {
            onerrorManaged?.value
        }
        set {
            guard let newValue else {
                onerrorManaged = nil
                return
            }
            onerrorManaged = JSManagedValue(value: newValue, andOwner: self)
        }
    }

    dynamic var readyState: Int = 0
    dynamic var status: Int = 0
    dynamic var statusText: String? = nil
    dynamic var responseText: String? = nil

    private var request: URLRequest?

    override required init() {}

    static func registerInto(jsContext: JSContext) {
        jsContext.setObject(XMLHttpRequest.self, forKeyedSubscript: "XMLHttpRequest" as NSCopying & NSObjectProtocol)
    }

    func open(_ method: String, _ url: String) {
        guard let url = URL(string: url) else { return }
        request = URLRequest(url: url)
        request?.httpMethod = method
        request?.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    }

    func send(_ data: String?) {
        guard let request else {
            fail(with: "invalid request")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // If we don't capture self here, it will be nil before the request finishes
            if let error {
                self.fail(with: error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                self.readyState = 4
                self.status = httpResponse.statusCode
                self.statusText = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)

                if let data {
                    self.responseText = String(data: data, encoding: .utf8)
                }

                self.onreadystatechange?.call(withArguments: [])
            } else {
                self.fail(with: "unknown error")
            }
        }
        task.resume()
    }

    func fail(with error: String) {
        status = 0
        statusText = error
        onerror?.call(withArguments: [])
    }
}
