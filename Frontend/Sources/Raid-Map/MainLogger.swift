//
//  PTLogger.swift
//  COpenSSL
//
//  Created  on 20.04.18.
//

import PerfectLib
import PerfectLogger

class MainLogger: Logger {
    
    public var debugLogFile = "/logs/debug.log"
    public var defaultLogFile = "/logs/default.log"
    public var errorLogFile = "/logs/error.log"
    
    private static var sharedLoc: MainLogger?
    public static var shared: MainLogger {
        if sharedLoc == nil {
            sharedLoc = MainLogger()
        }
        return sharedLoc!
    }
    
    func debug(message: String, _ even: Bool = false) {
        //ConsoleLogger().debug(message: message, even)
        LogFile.debug(message, logFile: debugLogFile, evenIdents: even)
    }
    
    func info(message: String, _ even: Bool = false) {
        //ConsoleLogger().info(message: message, even)
        let eventid = LogFile.info(message, logFile: debugLogFile, evenIdents: even)
        LogFile.info(message, eventid: eventid, logFile: defaultLogFile, evenIdents: even)
    }
    
    func warning(message: String, _ even: Bool = false) {
        ConsoleLogger().warning(message: message, even)
        let eventid = LogFile.warning(message, logFile: debugLogFile, evenIdents: even)
        LogFile.warning(message, eventid: eventid, logFile: defaultLogFile, evenIdents: even)
    }
    
    func error(message: String, _ even: Bool = false) {
        ConsoleLogger().error(message: message, even)
        let eventid = LogFile.error(message, logFile: debugLogFile, evenIdents: even)
        LogFile.error(message, eventid: eventid, logFile: defaultLogFile, evenIdents: even)
        LogFile.error(message, eventid: eventid, logFile: errorLogFile, evenIdents: even)
    }
    
    func critical(message: String, _ even: Bool = false) {
        ConsoleLogger().critical(message: message, even)
        let eventid = LogFile.critical(message, logFile: debugLogFile, evenIdents: even)
        LogFile.critical(message, eventid: eventid, logFile: defaultLogFile, evenIdents: even)
        LogFile.critical(message, eventid: eventid, logFile: errorLogFile, evenIdents: even)
    }
    
    func terminal(message: String, _ even: Bool = false) {
        ConsoleLogger().terminal(message: message, even)
    }
    
}
