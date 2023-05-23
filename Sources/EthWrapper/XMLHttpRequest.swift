import Foundation
import JavaScriptCore

@objc protocol XMLHttpRequestExports: JSExport {
    var onreadystatechange: JSValue? { get set }
    var readyState: Int { get }
    var status: Int { get }
    var responseText: String? { get }
    
    init()
    func open(_ method: String, _ url: String)
    func send(_ data: String?)
}

@objc class XMLHttpRequest: NSObject, XMLHttpRequestExports {
    dynamic var onreadystatechange: JSValue?
    dynamic var readyState: Int = 0
    dynamic var status: Int = 0
    dynamic var responseText: String? = nil

    private var request: URLRequest?
    
    required override init() {}
    
    static func registerInto(jsContext: JSContext) {
        jsContext.setObject(XMLHttpRequest.self, forKeyedSubscript: "XMLHttpRequest" as NSCopying & NSObjectProtocol)
    }
    
    func open(_ method: String, _ url: String) {
        guard let url = URL(string: url) else { return }
        self.request = URLRequest(url: url)
        self.request?.httpMethod = method
    }
    
    func send(_ data: String?) {
        guard let request = self.request else { return }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error)")
            } else if let httpResponse = response as? HTTPURLResponse {
                self.readyState = 4
                self.status = httpResponse.statusCode
                if let data = data {
                    self.responseText = String(data: data, encoding: .utf8)
                }
                self.onreadystatechange?.call(withArguments: [])
            }
        }
        task.resume()
    }
}
