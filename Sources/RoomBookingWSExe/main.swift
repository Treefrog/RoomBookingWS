//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger
import RoomBookingWS

RequestLogFile.location = "./log.log"

#if os(Linux)
    
var confData: [String:[[String:Any]]] = [
    "servers": [
        [
            "name":"RoomBooking",
            "port":80,
            "routes":[],
            "filters":[],
            "tlsConfig":[]
            
        ]
    ]
]
#else
    
var confData: [String:[[String:Any]]] = [
    "servers": [
        [
            "name":"RoomBooking",
            "port":8080,
            "routes":[],
            "filters":[]
            
        ]
    ]
]
    
#endif


// Load Filters
confData["servers"]?[0]["filters"] = filters()

// Load Routes
confData["servers"]?[0]["routes"] = makeRoutes()

do {
    #if os(Linux)
        try HTTPServer.runAs("webuser").launch(configurationData: confData)
    #else
        try HTTPServer.launch(configurationData: confData)
    #endif
    
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

