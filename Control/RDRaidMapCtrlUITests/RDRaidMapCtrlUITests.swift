//
//  RDRaidMapCtrlUITests.swift
//  RDRaidMapCtrlUITests
//
//  Created on 14.05.18.
//

import Foundation
import UIKit
import XCTest

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = cgImage!.dataProvider!.data!
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class TestAppTestUITests: XCTestCase {
    
    var screenshotDelay: Float = 1
    var uuid: String?
    var pokemon = false
    
    var terminate = false
    
    var new: Bool? = false
    var username: String?
    var password: String?
    
    var restartDelay = 600.0
    
    override func setUp() {
        super.setUp()
        
        if let value = Float(ProcessInfo.processInfo.environment["SCREENSHOT_DELAY"] ?? "") {
            screenshotDelay = value
        }
        if let value = Double(ProcessInfo.processInfo.environment["RESTART_DELAY"] ?? "") {
            restartDelay = value
        }
        if let value = ProcessInfo.processInfo.environment["UUID"] {
            uuid = value
        }
        if let value = Bool(ProcessInfo.processInfo.environment["POKEMON"] ?? "") {
            pokemon = value
        }
        
        if let value = Bool(ProcessInfo.processInfo.environment["TERMINATE"] ?? "") {
            terminate = value
        }
        
        if let value = Bool(ProcessInfo.processInfo.environment["NEW"] ?? "") {
            new = value
        }
        if let value = ProcessInfo.processInfo.environment["USERNAME"] {
            if value != "NONE" && value != "" {
                username = value
            }
        }
        if let value = ProcessInfo.processInfo.environment["PASSWORD"] {
            if value != "NONE" && value != "" {
                password = value
            }
        }
        
        continueAfterFailure = true
        
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func test0Start() {
        
        let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
        app.terminate()
        if terminate {
            print("Only Terminate PoGo Mode. Done!")
            return
        }
        
        app.activate()
        sleep(5)
    }
    
    func test1LoginSetup() {
        
        if terminate {
            return
        }
        
        if username != nil {
            
            let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
            let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            
            let newPlayerButton: XCUICoordinate
            let oldPlayerButton: XCUICoordinate
            let ptcButton: XCUICoordinate
            if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
                newPlayerButton = normalized.withOffset(CGVector(dx: 375, dy: 750))
                oldPlayerButton = normalized.withOffset(CGVector(dx: 375, dy: 925))
                ptcButton = normalized.withOffset(CGVector(dx: 375, dy: 950))
            } else {
                fatalError("Unsupported iOS modell. Please report this in our Discord!")
            }
            
            if new! {
                newPlayerButton.tap()
            } else {
                oldPlayerButton.tap()
            }
            sleep(2)
            ptcButton.tap()
        }
    }
    
    func test2LoginUsername() {
        
        if terminate {
            return
        }
        
        if username != nil {
            
            let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
            let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            
            let loginUsernameTextField: XCUICoordinate
            if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
                loginUsernameTextField = normalized.withOffset(CGVector(dx: 375, dy: 600))
            } else {
                fatalError("Unsupported iOS modell. Please report this in our Discord!")
            }
            
            sleep(2)
            loginUsernameTextField.tap()
            sleep(2)
            app.typeText(username!)

        }
        
    }
    
    func test3LoginPassword() {
        
        if terminate {
            return
        }
        
        if username != nil {
            
            let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
            let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            
            let loginPasswordTextField: XCUICoordinate
            if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
                loginPasswordTextField = normalized.withOffset(CGVector(dx: 375, dy: 700))
            } else {
                fatalError("Unsupported iOS modell. Please report this in our Discord!")
            }
            
            sleep(2)
            loginPasswordTextField.tap()
            sleep(2)
            app.typeText(password!)
            
        }
        
    }
    
    func test4LoginEnd() {
        
        if terminate {
            return
        }
        
        if username != nil {
            
            let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
            let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            
            let loginConfirmButton: XCUICoordinate
            if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
                loginConfirmButton = normalized.withOffset(CGVector(dx: 375, dy: 825))
            } else {
                fatalError("Unsupported iOS modell. Please report this in our Discord!")
            }
            
            sleep(2)
            loginConfirmButton.tap()
        }
    }
    
    func test5Main() {
        
        if terminate {
            return
        }
        
        DispatchQueue.global().async {
            while true {
                usleep(useconds_t(self.screenshotDelay * 1000000))
                
                let screenshot = XCUIScreen.main.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.lifetime = .keepAlways
                if let uuid = self.uuid {
                    attachment.name = "\(uuid)_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString)"
                }
                self.add(attachment)
            }
        }
        
        let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
        
        var startupCount = 0
        var isStarted = false
        var isStartupCompleted = false
        var startupImageSize = 0
        var appStart = Date()
        
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        let coordStartup: XCUICoordinate
        let coordPassenger: XCUICoordinate
        let coordNearby: XCUICoordinate
        let coordRaids: XCUICoordinate
        let coordWeather1: XCUICoordinate
        let coordWeather2: XCUICoordinate
        let coordWarning: XCUICoordinate
        let comparePosition: (x: Int, y: Int)
        
        if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 375, dy: 800))
            coordPassenger = normalized.withOffset(CGVector(dx: 275, dy: 950))
            coordNearby = normalized.withOffset(CGVector(dx: 600, dy: 1200))
            coordRaids = normalized.withOffset(CGVector(dx: 550, dy: 450))
            coordWeather1 = normalized.withOffset(CGVector(dx: 225, dy: 1145))
            coordWeather2 = normalized.withOffset(CGVector(dx: 225, dy: 1270))
            coordWarning = normalized.withOffset(CGVector(dx: 375, dy: 1125))
            comparePosition = (300, 1300)
        } else if app.frame.size.width == 768 { //iPad 9,7 (Air, Air2, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 768, dy: 1234))
            coordPassenger = normalized.withOffset(CGVector(dx: 768, dy: 1567))
            coordNearby = normalized.withOffset(CGVector(dx: 1387, dy: 1873))
            coordRaids = normalized.withOffset(CGVector(dx: 1124, dy: 120))
            coordWeather1 = normalized.withOffset(CGVector(dx: 1300, dy: 1700))
            coordWeather2 = normalized.withOffset(CGVector(dx: 768, dy: 2000))
            coordWarning = normalized.withOffset(CGVector(dx: 768, dy: 1700))
            comparePosition = (0, 0)
        } else if app.frame.size.width == 320 { //iPhone Small (5S, SE, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 325, dy: 655))
            coordPassenger = normalized.withOffset(CGVector(dx: 230, dy: 790))
            coordNearby = normalized.withOffset(CGVector(dx: 550, dy: 1040))
            coordRaids = normalized.withOffset(CGVector(dx: 470, dy: 335))
            coordWeather1 = normalized.withOffset(CGVector(dx: 0, dy: 0))
            coordWeather2 = normalized.withOffset(CGVector(dx: 0, dy: 0))
            coordWarning = normalized.withOffset(CGVector(dx: 320, dy: 960))
            comparePosition = (0, 0)
        } else if app.frame.size.width == 414 { //iPhone Large (6+, 7+, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 621, dy: 1275))
            coordPassenger = normalized.withOffset(CGVector(dx: 820, dy: 1540))
            coordNearby = normalized.withOffset(CGVector(dx: 1060, dy: 2020))
            coordRaids = normalized.withOffset(CGVector(dx: 880, dy: 655))
            coordWeather1 = normalized.withOffset(CGVector(dx: 0, dy: 0))
            coordWeather2 = normalized.withOffset(CGVector(dx: 0, dy: 0))
            coordWarning = normalized.withOffset(CGVector(dx: 0, dy: 0))
            comparePosition = (0, 0)
        } else {
            fatalError("Unsupported iOS modell. Please report this in our Discord!")
        }
        
        while true {
            
            if Date().timeIntervalSince(appStart) >= restartDelay {
                print("Restarting Pokemon Go")
                app.terminate()
            }
            
            if app.state == .notRunning {
                startupCount = 0
                isStarted = false
                isStartupCompleted = false
                startupImageSize = 0
                appStart = Date()
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
                        coordWarning.tap()
                        sleep(2)
                    }
                    coordWeather1.tap()
                    sleep(2)
                    coordWeather2.tap()
                    sleep(2)
                    if app.state == .runningForeground {
                        coordNearby.tap()
                        sleep(2)
                    }
                    if app.state == .runningForeground {
                        for _ in 0...5 {
                            coordPassenger.tap()
                            usleep(1000)
                            coordNearby.tap()
                            usleep(1000)
                        }
                        sleep(2)
                    }
                    if !pokemon {
                        for _ in 0...20 {
                            if app.state == .runningForeground {
                                coordPassenger.tap()
                                usleep(1000)
                                coordRaids.tap()
                                usleep(1000)
                            }
                        }
                    }
                    isStartupCompleted = true
                } else {
                    
                    if comparePosition.x != 0 && comparePosition.y != 0 {
                        let color = screenshot.image.getPixelColor(pos: CGPoint(x: comparePosition.x, y: comparePosition.y))
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        print(red, green, blue, alpha)
                        if red < 0.9 || green < 0.9 || blue < 0.9 {
                            print("We are stuck somewhere. Restarting...")
                            app.terminate()
                            continue
                        }
                    }
                    
                    print("App is running")
                    coordWeather1.tap()
                    coordWeather2.tap()
                    sleep(4)
                }
            } else if screenshotSize > startupImageSize - 100000 && screenshotSize < startupImageSize + 100000 {
                print("App still in Startup")
                if startupCount == 30 {
                    app.terminate() // Retry
                }
                startupCount += 1
            } else {
                isStarted = true
            }
            
        }
    }

    func logOut(app: XCUIApplication) {
        
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        let closeMenuButton: XCUICoordinate
        let settingsButton: XCUICoordinate
        let dragStart: XCUICoordinate
        let dragEnd: XCUICoordinate
        let logoutButton: XCUICoordinate
        let logoutConfirmButton: XCUICoordinate
        if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
            closeMenuButton = normalized.withOffset(CGVector(dx: 375, dy: 1215))
            settingsButton = normalized.withOffset(CGVector(dx: 700, dy: 215))
            dragStart = normalized.withOffset(CGVector(dx: 375, dy: 1000))
            dragEnd = normalized.withOffset(CGVector(dx: 375, dy: 100))
            logoutButton = normalized.withOffset(CGVector(dx: 500, dy: 575))
            logoutConfirmButton = normalized.withOffset(CGVector(dx: 375, dy: 725))
        } else {
            fatalError("Unsupported iOS modell. Please report this in our Discord!")
        }
        
        //closeMenuButton.tap()
        //sleep(2)
        closeMenuButton.tap()
        sleep(2)
        settingsButton.tap()
        sleep(2)
        dragStart.press(forDuration: 0.1, thenDragTo: dragEnd)
        sleep(2)
        logoutButton.tap()
        sleep(2)
        logoutConfirmButton.tap()
        
        
        
        
    }

}
