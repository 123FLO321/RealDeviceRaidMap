//
//  DB.swift
//  COpenSSL
//
//  Created on 20.04.18.
//

import Foundation
import PerfectLib
import PerfectMySQL

class DB {
    
    private static var host = ProcessInfo.processInfo.environment["DB_HOST"] ?? "127.0.0.1"
    private static var port = Int(ProcessInfo.processInfo.environment["DB_PORT"] ?? "") ?? 3306
    private static var username = ProcessInfo.processInfo.environment["DB_USERNAME"] ?? "root"
    private static var password = ProcessInfo.processInfo.environment["DB_PASSWORD"] ?? ""
    private static var database = ProcessInfo.processInfo.environment["DB_DBNAME"] ?? "monocledb"

    public static var mysql: MySQL? {
        let mysql = MySQL()
        mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8")
        let connected = mysql.connect(host: host, user: username, password: password, db: database)
        if connected {
            return mysql
        } else {
            return nil
        }
    }

}
