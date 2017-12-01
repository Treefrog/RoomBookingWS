//
//  filters.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

import PerfectHTTPServer
import PerfectRequestLogger

public func filters() -> [[String: Any]] {
    
    var filters: [[String: Any]] = [[String: Any]]()
    filters.append(["type":"response","priority":"high","name":PerfectHTTPServer.HTTPFilter.contentCompression])
    filters.append(["type":"request","priority":"high","name":RequestLogger.filterAPIRequest])
    filters.append(["type":"response","priority":"low","name":RequestLogger.filterAPIResponse])
    
    return filters
}
