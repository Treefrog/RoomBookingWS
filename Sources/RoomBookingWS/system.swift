//
//  system.swift
//  Room-BookingPackageDescription
//
//  Created by Fareed Quraishi on 2017-11-24.
//

import PerfectLib
import PerfectPostgreSQL
import PerfectLogger
import PerfectSMTP
import Foundation

class System {
    static let shared = System()
    static let smtpClient = SMTPClient(url: "smtps://mail.treefrog.ca", username: "roombooking@treefrog.ca", password:"\(dbPassword)")
    
    var databaseConnection:PGConnection {
        get {
            let pgsl = PerfectPostgreSQL.PGConnection()
            let _ = pgsl.connectdb("host=\(databaseIP) dbname=\(dbDatabaseName) port=5432 user=\(dbUsername) password='\(dbPassword)'")
            return pgsl
        }
    }
    
    func sendEmailResponse(toEmail:String, fromEmail:String, subject:String, content:String){
        let email = EMail(client: System.smtpClient)
        
        email.to.append(Recipient(name: toEmail, address: toEmail))
        email.from = Recipient(name: fromEmail, address: fromEmail)
        email.subject = subject
        email.html = content
        
        do {
            try email.send { code, header, body in
                LogFile.info("Successfully sent an email to \(toEmail)")
            }
        }catch {
            LogFile.critical("Failed to send an email to \(toEmail)")
        }
    }
    
}
