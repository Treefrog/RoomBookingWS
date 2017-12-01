//
//  routes.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

public func makeRoutes() -> [[String: Any]] {
    var routes: [[String: Any]] = [[String: Any]]()

    //To give ability to server static files
    routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
                   "documentRoot":"./webroot",
                   "allowResponseFilters":true])
    
    routes.append(["method":"get", "uri":"/", "handler":Routes.webforum])
    
    routes.append(["method":"post", "uri":"/API/v1/room", "handler":Routes.createNewRoom])
    routes.append(["method":"get", "uri":"/API/v1/room", "handler":Routes.getAllRoom])
    
    routes.append(["method":"post", "uri":"/API/v1/booking", "handler":Routes.createNewBooking])
    routes.append(["method":"get", "uri":"/API/v1/booking", "handler":Routes.getAllBooking])
    routes.append(["method":"delete", "uri":"/API/v1/booking", "handler":Routes.deleteBooking])
    
    return routes
}

class Routes {
    
    static func createNewRoom(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            response.setHeader(.contentType, value: "application/json")
            
            var params = request.getParams()
            guard let name = params["name"] as? String
                else  {
                    response.invalidInput()
                    return
            }
            
            let room = Room(name: name)
            room.insert(failure: {
                let responseJSON = ["error":"failed to insert room"]
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            let responseJSON = ["success":"successfully inserted room"]
            let _ = try? response.setBody(json: responseJSON)
            response.completed()
        }
    }
    
    static func getAllRoom(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            response.setHeader(.contentType, value: "application/json")
            var responseJSON = [[String:Any]]()
            
            let allRooms = Room.loadAll(failure: {
                responseJSON.append(["error":"failed to load rooms"])
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            responseJSON.append(["results":allRooms])
            let _ = try? response.setBody(json: responseJSON)
            response.completed()
        }
    }
    
    static func createNewBooking(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            response.setHeader(.contentType, value: "application/json")
            
            var params = request.getParams()
            guard let title = params["title"] as? String,
                let requester = params["requester"] as? String,
                let date = params["date"] as? String,
                let start = params["start"] as? String,
                let end = params["end"] as? String,
                let room_id = params["room_id"] as? String,
                let attendies = params["attendies"] as? String,
                let requirements = params["requirements"] as? String,
                let description = params["description"] as? String
                else  {
                    response.invalidInput()
                    return
            }
            
            if !start.isProperTime() || !end.isProperTime() || !date.isProperDate() {
                let responseJSON = ["error":"data provided were not in proper format"]
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            }
            
            let booking = Booking(title: title, requester: requester, date: date.toDate(), start: start, end: end, room_id: room_id, attendies: attendies, requirements: requirements, description: description, failure: { reason in
                let responseJSON = ["error":"failed to create new booking", reason: reason]
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            booking.insert(failure: {
                let responseJSON = ["error":"failed to create new booking"]
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            let responseJSON = ["success":"successfully inserted booking", "id":booking.id]
            let _ = try? response.setBody(json: responseJSON)
            response.completed()
        }
    }
    
    static func deleteBooking(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            response.setHeader(.contentType, value: "application/json")
            var responseJSON = [[String:String]]()
            
            var params = request.getParams()
            guard let id = params["id"] as? String
                else  {
                    response.invalidInput()
                    return
            }
            
            Booking.delete(id: id, failure: {
                responseJSON.append(["error":"failed to delete booking"])
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            responseJSON.append(["success":"sucessfully deleted booking"])
            let _ = try? response.setBody(json: responseJSON)
            response.completed()
        }
    }
    
    static func getAllBooking(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            response.setHeader(.contentType, value: "application/json")
            var responseJSON = [[String:Any]]()
            
            let allRooms = Booking.loadAll(failure: {
                responseJSON.append(["error":"failed to load all bookings"])
                let _ = try? response.setBody(json: responseJSON)
                response.completed()
                return
            })
            
            responseJSON.append(["results":allRooms])
            let _ = try? response.setBody(json: responseJSON)
            response.completed()
        }
    }
    
    static func webforum(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            let webRoot = request.documentRoot
            mustacheRequest(request: request, response: response, handler: adminHandler(), templatePath: webRoot + "/index.html")
        }
    }
    
    struct adminHandler: MustachePageHandler {
        func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
            var values = MustacheEvaluationContext.MapType()
            let response = contxt.webResponse
            
            do {
                
                values["rooms"] = Room.loadAll(failure: { })
                
                contxt.extendValues(with: values)
                try contxt.requestCompleted(withCollector: collector)
            } catch {
                response.status = .internalServerError
                response.appendBody(string: "\(error)")
                response.completed()
            }
        }
    }
}
