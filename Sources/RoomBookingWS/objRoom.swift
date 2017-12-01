//
//  objRoom.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-29.
//

//
//  objBooking.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

import PerfectLib
import PerfectPostgreSQL
import PerfectLogger

fileprivate let queryLoadRoom:String = "SELECT * FROM rooms WHERE id = $1"
fileprivate let queryLoadAllRooms:String = "SELECT * FROM rooms"
fileprivate let queryInsertRoom:String = "INSERT INTO rooms (id, name) VALUES ($1, $2)"
fileprivate let queryDeleteRoom:String = "DELETE FROM rooms WHERE id = $1"

class Room {
    var id : String
    var name : String
    
    init(name:String = ""){
        id = UUID().string
        self.name = name
    }
    
    convenience init(id: String, failure:@escaping()->()) {
        self.init()
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let params = [id]
        let databaseResponse = pgsl.exec(statement: queryLoadRoom, params:params)
        if databaseResponse.status() != .tuplesOK {
            LogFile.critical("Database issue running this command \(queryLoadRoom)")
            failure()
            return
        }
        
        if databaseResponse.numTuples() != 1 {
            LogFile.critical("Database issue - did not return 1 results with this command \(queryLoadRoom)")
            failure()
            return
        }
            

        let currentData = extractRoom(databaseResponse: databaseResponse, index: 0, failure: {
            failure()
            return
        })
        
        guard let id = currentData["id"],
            let name = currentData["name"] else {
                failure()
                return
        }
        self.id = id
        self.name = name
    }
    
    static func loadAll(failure:@escaping ()->()) -> [[String:String]] {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let databaseResponse = pgsl.exec(statement: queryLoadAllRooms)
        if databaseResponse.status() != .tuplesOK {
            LogFile.critical("Database issue running this command \(queryLoadAllRooms)")
            failure()
            return [[String:String]]()
        }
        
        var returnData = [[String:String]]()
        for index in 0..<databaseResponse.numTuples() {
            
            let currentData = Room().extractRoom(databaseResponse: databaseResponse, index: index, failure: {
                failure()
                return
            })
            
            returnData.append(currentData)
        }
        
        return returnData
    }
    
    private func extractRoom(databaseResponse:PGResult, index:Int, failure:@escaping()->()) -> [String:String] {
        guard let id = databaseResponse.getFieldString(tupleIndex: index, fieldIndex: 0) else {
            LogFile.critical("Database issue with extracting tupleIndex \(index) with fieldIndex 0 in this query \(queryLoadAllRooms)")
            failure()
            return [String:String]()
        }
        
        guard let name = databaseResponse.getFieldString(tupleIndex: index, fieldIndex: 1) else {
            LogFile.critical("Database issue with extracting tupleIndex \(index) with fieldIndex 1 in this query \(queryLoadAllRooms)")
            failure()
            return [String:String]()
        }
        
        return ["id":id, "name":name]
    }
    
    func insert(failure:@escaping ()->()) {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let params = [id, name]
        
        let databaseResponse = pgsl.exec(statement: queryInsertRoom, params: params)
        if databaseResponse.status() != .commandOK {
            LogFile.critical("Database issue running this command \(queryInsertRoom)")
            failure()
            return
        }
        
        return
    }
    
    static func delete(id:String, failure:@escaping ()->()) {
        let pgsl = System.shared.databaseConnection
        defer { pgsl.close() }
        
        let params = [id]
        
        let databaseResponse = pgsl.exec(statement: queryDeleteRoom, params: params)
        if databaseResponse.status() != .commandOK {
            LogFile.critical("Database issue running this command \(queryDeleteRoom)")
            failure()
            return
        }
        
        return
    }
}

