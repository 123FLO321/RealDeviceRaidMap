//
//  RDRaidMapCtrlUITests.swift
//  RDRaidMapCtrlUITests
//
//  Created on 14.05.18.
//

import XCTest

class TestAppTestUITests: XCTestCase {
    
    let screenshotDelay: UInt32 = 4 // real delay is one higher
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testExample() {
        
        let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
        var startupCount = 0
        var isStarted = !(app.state == .notRunning)
        var isStartupCompleted = !(app.state == .notRunning)
        var startupImageSize = 0
        var roundCount = 0
        
        app.activate()
        sleep(1)
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        let coordStartup: XCUICoordinate
        let coordPassenger: XCUICoordinate
        let coordNearby: XCUICoordinate
        let coordRaids: XCUICoordinate
        
        if app.frame.size.width == 375 { //iPhone
            coordStartup = normalized.withOffset(CGVector(dx: 375, dy: 800))
            coordPassenger = normalized.withOffset(CGVector(dx: 375, dy: 950))
            coordNearby = normalized.withOffset(CGVector(dx: 600, dy: 1200))
            coordRaids = normalized.withOffset(CGVector(dx: 550, dy: 450))
        } else if app.frame.size.width == 768 { //iPad
            coordStartup = normalized.withOffset(CGVector(dx: 768, dy: 1234))
            coordPassenger = normalized.withOffset(CGVector(dx: 768, dy: 1567))
            coordNearby = normalized.withOffset(CGVector(dx: 1387, dy: 1873))
            coordRaids = normalized.withOffset(CGVector(dx: 1124, dy: 120))
        } else {
            fatalError("Unsupported iOS modell. Please report this in our Discord!")
        }
        
        while true {
            
            if roundCount >= 100 {
                app.terminate()
            }
            
            if app.state == .notRunning {
                startupCount = 0
                isStarted = false
                isStartupCompleted = false
                startupImageSize = 0
                roundCount = 0
                app.activate()
                sleep(1)
            }
            else if app.state != .runningForeground {
                app.activate()
                sleep(1)
            }
            
            if app.state == .runningForeground {
                coordPassenger.tap()
                sleep(1)
            }
            let screenshot = XCUIScreen.main.screenshot()
            let screenshotSize = screenshot.pngRepresentation.count
            
            if startupCount == 0 {
                startupImageSize = screenshotSize
            }
            
            if isStarted {
                if !isStartupCompleted {
                    print("Performing Startup sequence")
                    if app.state == .runningForeground {
                        coordStartup.tap()
                        sleep(2)
                    }
                    if app.state == .runningForeground {
                        coordNearby.tap()
                        sleep(2)
                    }
                    if app.state == .runningForeground {
                        coordNearby.tap()
                        sleep(2)
                    }
                    for _ in 0...5 {
                        if app.state == .runningForeground {
                            coordRaids.tap()
                            usleep(10000)
                        }
                    }
                    isStartupCompleted = true
                } else {
                    print("App is running")
                    let attachment = XCTAttachment(screenshot: screenshot)
                    attachment.lifetime = .keepAlways
                    add(attachment)
                    sleep(screenshotDelay)
                }
            } else if screenshotSize > startupImageSize - 100000 && screenshotSize < startupImageSize + 100000 {
                print("App still in Startup")
                if startupCount == 10 {
                    app.terminate() // Retry
                }
                startupCount += 1
            } else {
                isStarted = true
            }
            
            roundCount += 1
        }
    }
}
