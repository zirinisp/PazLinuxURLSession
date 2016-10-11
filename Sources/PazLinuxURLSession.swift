#if os(Linux)

import Foundation
import SimpleHttpClient
import KituraNet
import Glibc


public class HTTPSession {
    let configuration: HTTPSessionConfiguration
    
    public init(configuration: HTTPSessionConfiguration) {
        self.configuration = configuration
    }
    
    public func dataTaskWithURL(url: URL, completion: @escaping HTTPCompletionFunc) -> HTTPSessionDataTask {
        return HTTPSessionDataTask(configuration: configuration, URL: url, completion: completion)
    }
}


public class HTTPSessionConfiguration {
    public var HTTPAdditionalHeaders = [String:String]()
    
    public class func defaultSessionConfiguration() -> HTTPSessionConfiguration {
        return HTTPSessionConfiguration()
    }
}

public typealias HTTPCompletionFunc = ((NSData?, HTTPURLResponse?, NSError?) -> Void)

public class HTTPSessionDataTask {
    let completion: HTTPCompletionFunc
    let configuration: HTTPSessionConfiguration
    let URL: URL
    
    internal init(configuration: HTTPSessionConfiguration, URL: URL, completion: @escaping HTTPCompletionFunc) {
        self.completion = completion
        self.configuration = configuration
        self.URL = URL
    }
    
    private func makeError(message: String? = nil) -> NSError {
        #if os(Linux)
            var userInfo = [String:Any]()
        #else
            var userInfo = [String:String]()
        #endif
        
        if let message = message {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        return NSError(domain:"org.vu0.RequestSession", code: 23, userInfo: userInfo)
    }
    
    private func perform() {
        #if os(Linux)
            let urlString = URL.absoluteString!
        #else
            let urlString = URL.absoluteString
        #endif
        
        let headers = configuration.HTTPAdditionalHeaders
        
        guard let scheme = URL.scheme, let host = URL.host, let portInt = URL.port else {
            completion(nil, nil, makeError(message: "Could not break down url. \(URL.absoluteString)"))
            return
        }
        let port = "\(portInt)"
        let pathExtension = URL.pathExtension
        
        
        let httpResource = HttpResource(schema: scheme, host: host, port: port, path: pathExtension)

        HttpClient.get(resource: httpResource, headers: headers) { (error, status, headers, data) in
            if error != nil {
                print("Failure")
            } else if let _ = data {
                print("Success")
            }
            completion(data, nil, error)
        }
    }
    
    public func resume() {
        async { self.perform() }
    }
}

func async(block: (Void) -> Void) {
    block()
}

extension String {
    func dataUsingEncoding(encoding: UInt) -> NSData? {
        self.withCString { (bytes) in
            return NSData(bytes: bytes, length: Int(strlen(bytes)))
        }
        return nil
    }
}
    
#endif