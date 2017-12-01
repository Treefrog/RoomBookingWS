//
//  extensions.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif
import Foundation
import PerfectLib
import PerfectHTTP

extension String {
    public var sysEnv: String {
        guard let e = getenv(self) else { return "" }
        return String(cString: e)
    }
    
    func isValidEmail() -> Bool {
        #if os(Linux) && !swift(>=3.1)
            let regex = try? RegularExpression(pattern: "^[A-Za-z][A-Z0-9a-z.-_]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}$", options: .caseInsensitive)
        #else
            let regex = try? NSRegularExpression(pattern: "^[A-Za-z][A-Z0-9a-z.-_]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}$", options: .caseInsensitive)
        #endif
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public func isProperTime() -> Bool {
        #if os(Linux) && !swift(>=3.1)
            let regex = try? RegularExpression(pattern: "^\\d\\d:\\d\\d$", options: .caseInsensitive)
        #else
            let regex = try? NSRegularExpression(pattern: "\\d\\d:\\d\\d", options: .caseInsensitive)
        #endif
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public func isProperDate() -> Bool {
        #if os(Linux) && !swift(>=3.1)
            let regex = try? RegularExpression(pattern: "^\\d\\d/\\d\\d/\\d\\d\\d\\d$", options: .caseInsensitive)
        #else
            let regex = try? NSRegularExpression(pattern: "\\d\\d/\\d\\d/\\d\\d\\d\\d", options: .caseInsensitive)
        #endif
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: Locale(identifier: "en-GB"))
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}

extension HTTPRequest {
    func isMobile() -> Bool {
        if let userAgentString = self.header(HTTPRequestHeader.Name.userAgent) {
            if userAgentString.substring(to: userAgentString.index(userAgentString.startIndex, offsetBy: 6)) == "uMunch" || userAgentString.substring(to: userAgentString.index(userAgentString.startIndex, offsetBy: 6)) == "Dalvik" {
                return true
            }
        }
        return false
    }
    
    private func getWebParams() -> [String:String] {
        guard let input = self.postBodyString?.stringByDecodingURL! else {
            return [String:String]()
        }
        do {
            if input.contains("=") {
                guard let newInput = self.postBodyString?.stringByDecodingURL!.components(separatedBy: "&") else {
                    return [String:String]()
                }
                var final = [String:String]()
                if newInput[0].isEmpty { return final }
                for param in newInput {
                    let element = param.components(separatedBy: "=")
                    final[element[0]] = element[1]
                }
                return final
            } else {
                return try input.jsonDecode() as! [String : String]
            }
        } catch {
            return [String:String]()
        }
    }
    
    private func getJSONParams() -> [String:Any] {
        
        let input = self.postBodyString
        do {
            let params = try input?.jsonDecode() as! [String:Any]
            return params
        } catch {
            return [String:Any]()
        }
    }
    
    private func getGetParams() -> [String:String] {
        var final = [String:String]()
        let inputs = self.queryParams
        for input in inputs {
            final[input.0] = input.1
        }
        return final
    }
    
    func getParams() -> [String:Any] {
        var params = [String:Any]()
        if "\(self.method)" == "GET" {
            params = self.getGetParams()
        } else if self.isMobile() {
            params = self.getJSONParams()
        } else {
            params = self.getWebParams()
        }
        return params
    }
}

extension HTTPResponse {
    
    func invalidInput() {
        do {
            try self.setBody(json: ["error": "Invalid Input"])
        } catch {
            print(error)
        }
        self.completed()
    }
}
