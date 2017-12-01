//
//  objBooking.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

import Foundation
import PerfectLib
import PerfectPostgreSQL
import PerfectLogger

fileprivate let queryLoadAllBookings:String = "SELECT * FROM bookings"
fileprivate let queryInsertBooking:String = "INSERT INTO bookings (id, title, requester, date, start_time, end_time, room_id, attendees, requirements, description) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)"
fileprivate let queryDeleteBooking:String = "DELETE FROM bookings WHERE id = $1"

class Booking {
    var id : String
    var title : String
    var requester : String
    var date : Date
    var start : String
    var end : String
    var room : Room
    var attendees : String
    var requirements : String
    var description : String
    
    init(title:String, requester:String, date:Date, start:String, end:String, room_id:String, attendies:String, requirements:String, description:String, failure:@escaping(_ reason:String)->()){
        self.id = UUID().string
        self.title = title
        self.requester = requester
        self.date = date
        self.start = start
        self.end = end
        self.room = Room(id: room_id, failure: {
            failure("Room_id didn't load a room")
        })
        self.attendees = attendies
        self.requirements = requirements
        self.description = description
    }
    
    static func loadAll(failure:@escaping ()->()) -> [[String:String]] {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let databaseResponse = pgsl.exec(statement: queryLoadAllBookings)
        if databaseResponse.status() != .tuplesOK {
            LogFile.critical("Database issue running this command \(queryLoadAllBookings)")
            failure()
            return [[String:String]]()
        }
        
        var returnData = [[String:String]]()
        for index in 0..<databaseResponse.numTuples() {
            
            guard let id = databaseResponse.getFieldString(tupleIndex: index, fieldIndex: 0) else {
                LogFile.critical("Database issue with extracting tupleIndex \(index) with fieldIndex 0 in this query \(queryLoadAllBookings)")
                failure()
                return [[String:String]]()
            }
            
            guard let name = databaseResponse.getFieldString(tupleIndex: index, fieldIndex: 1) else {
                LogFile.critical("Database issue with extracting tupleIndex \(index) with fieldIndex 1 in this query \(queryLoadAllBookings)")
                failure()
                return [[String:String]]()
            }
            
            let currentData = ["id":id, "name":name]
            returnData.append(currentData)
        }
        
        return returnData
    }
    
    func insert(failure:@escaping ()->()) {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let params = [self.id, self.title, self.requester, self.date, self.start, self.end, self.room.id, self.attendees, self.requirements, self.description] as [Any]
        
        let databaseResponse = pgsl.exec(statement: queryInsertBooking, params: params)
        if databaseResponse.status() != .commandOK {
            LogFile.critical("Database issue running this command \(queryInsertBooking)")
            failure()
            return
        }
    }
    
    
    static func delete(id:String, failure:@escaping ()->()) {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let params = [id]
        
        let databaseResponse = pgsl.exec(statement: queryDeleteBooking, params: params)
        if databaseResponse.status() != .commandOK {
            LogFile.critical("Database issue running this command \(queryDeleteBooking)")
            failure()
            return
        }
    }
}
