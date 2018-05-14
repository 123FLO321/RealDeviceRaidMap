//
//  main.swift
//  PT-Wworld
//
//  Created  on 19.04.18.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
//import PerfectSession
//import PerfectSessionMySQL
import PerfectLogger

print("Enviroment: \(ProcessInfo.processInfo.environment)")

do {
try Dir(Dir.workingDir.path + "/log").create()
try Dir(Dir.workingDir.path + "/inbox").create()
} catch {}

MainLogger.shared.debugLogFile = Dir.workingDir.path + "/log/debug.log"
MainLogger.shared.defaultLogFile =  Dir.workingDir.path + "/log/default.log"
MainLogger.shared.errorLogFile =  Dir.workingDir.path + "/log/error.log"

Log.logger = MainLogger.shared

Log.critical(message: "-----------------------------------------------------")
Log.critical(message: "---------------Starting Server V.1.0.0---------------")
Log.critical(message: "-----------------------------------------------------")

var serverName = ProcessInfo.processInfo.environment["SERVER_NAME"] ?? "RaidMapHelper"
var serverAddress = ProcessInfo.processInfo.environment["SERVER_HOST"] ?? "0.0.0.0"
var serverPort = Int(ProcessInfo.processInfo.environment["SERVER_PORT"] ?? "") ?? 8181

/*
SessionConfig.name = "SESSION-TOKEN"
SessionConfig.idle = 2592000

// Optional
SessionConfig.cookieDomain = serverAddress
SessionConfig.cookieSecure = false
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = false
SessionConfig.CSRF.checkHeaders = true
SessionConfig.CSRF.requireToken = true

SessionConfig.CORS.enabled = false
SessionConfig.CORS.methods = [.get, .post]
SessionConfig.CORS.acceptableHostnames.append("::1")
SessionConfig.CORS.maxAge = 3600
*/
DB.initDB()
InputManager.start()

//let sessionDriver = SessionMySQLDriver()

var serverRoutes = Routes([
    // HOME
    Route(method: .get, uri: "/", handler: { (request, response) in
        MainRequestHandler.handle(request: request, response: response, page: .home)
    }),
    // SEAERCH
    Route(method: .post, uri: "/search", handler: { (request, response) in
        MainRequestHandler.handle(request: request, response: response, page: .search)
    }),
    Route(method: .post, uri: "/delete", handler: { (request, response) in
        MainRequestHandler.handle(request: request, response: response, page: .delete)
    }),
    Route(method: .post, uri: "/submit", handler: { (request, response) in
        MainRequestHandler.handle(request: request, response: response, page: .submit)
    }),
    // STATIC
    Route(method: .get, uri: "/static/**", handler: { (request, response) in
        StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        response.completed()
    })
])

//AuthFilter.authenticationConfig.include("*")

let server = HTTPServer.Server(name: serverName, address: serverAddress, port: serverPort, routes: serverRoutes/*, requestFilters: [sessionDriver.requestFilter], responseFilters: [sessionDriver.responseFilter]*/)

do {
    try HTTPServer.launch([server])
} catch {
    fatalError("\(error)")
}

extension Optional where Wrapped == Int {
    var dbString: String {
        if self == nil {
            return "NULL"
        } else {
            return self!.description
        }
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZone: TimeZone = TimeZone.current) -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = timeZone
        components.hour = hour
        components.minute = min
        components.second = sec
        
        return cal.date(from: components)
    }
}
