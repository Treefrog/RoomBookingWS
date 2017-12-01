import XCTest
import PerfectHTTPServer
import PerfectHTTP
import PerfectCURL
@testable import RoomBookingWS

class RoomBookingWSTests: XCTestCase {
    
    func testValidTimeFormat() {
        XCTAssert("00:00".isProperTime())
    }
    
    func testNotValidTimeFormat() {
        XCTAssertFalse("A0:00".isProperTime())
    }
    
    func testValidDateFormat() {
        XCTAssert("11/29/2017".isProperDate())
    }
    
    func testNotValidDateFormat() {
        XCTAssertFalse("11/29/2s17".isProperDate())
    }
    
    func testValidEmailFormat() {
        XCTAssert("a@a.ca".isValidEmail())
    }
    
    func testNotValidEmailFormat() {
        XCTAssertFalse("1@a.ca".isValidEmail())
    }
    
    func testRoomDBCommands() {
        let testRoomName = "testRoom"
        
        //Get original count of rooms
        var allRooms = Room.loadAll(failure: {})
        var originalCount = allRooms.count
        
        //Ensure a room can be added
        let newRoom = Room(name: testRoomName)
        newRoom.insert(failure: {})
        allRooms = Room.loadAll(failure: {})
        XCTAssertTrue(allRooms.count == originalCount + 1)
        
        //Ensure a room can be loaded with it's id
        var room = Room(id: newRoom.id, failure: {})
        XCTAssert(room.name == testRoomName)
        
        //Ensure a room can be deleted
        Room.delete(id: newRoom.id, failure: {})
        allRooms = Room.loadAll(failure: {})
        XCTAssertTrue(allRooms.count == originalCount)
    }
    
    func testBookingDBCommands() {
        let title = "Client Meeting"
        let requester = "fareed@treefrog.ca"
        let date = "2017-11-11"
        let start = "13:00"
        let end = "14:00"
        let room_id = "09e12ef1-3cbd-49d7-b3a2-f8c9fef13b76"
        let attendies = "Tom, Harry, Joe"
        let requirements = "Want Sandwiches"
        let description = "Making money!!"
        
        //Get original count of bookings
        var allBookings = Booking.loadAll(failure: {})
        var originalCount = allBookings.count
        
        //Ensure a room can be added
        let newBooking = Booking(title: title, requester: requester, date: date.toDate(), start: start, end: end, room_id: room_id, attendies: attendies, requirements: requirements, description: description, failure: { _ in})
        newBooking.insert(failure: {})
        allBookings = Booking.loadAll(failure: {})
        XCTAssertTrue(allBookings.count == originalCount + 1)
        
        //Ensure a room can be deleted
        Booking.delete(id: newBooking.id, failure: {})
        allBookings = Booking.loadAll(failure: {})
        XCTAssertTrue(allBookings.count == originalCount)
    }
}
