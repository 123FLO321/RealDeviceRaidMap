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
        
        let pixelInfo: Int = ((Int(cgImage!.width) * Int(pos.y)) + Int(pos.x)) * 4
        
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
            print("[DEBUG] Only Terminate PoGo Mode. Done!")
            return
        }
        
        app.activate()
        //sleep(5)
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
                print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
                XCTFail()
                return
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
                print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
                XCTFail()
                return
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
                print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
                XCTFail()
                return
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
                print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
                XCTFail()
                return
            }
            
            sleep(2)
            loginConfirmButton.tap()
        }
    }
    
    func test5Main() {
        
        if terminate {
            return
        }
        
        let lock = NSLock()
        var attachments = [XCTAttachment]()

        DispatchQueue.global().async {
            while true {
                usleep(useconds_t(self.screenshotDelay * 1000000))
                let screenshot = XCUIScreen.main.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.lifetime = .keepAlways
                if let uuid = self.uuid {
                    attachment.name = "\(uuid)_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString)"
                }
                lock.lock()
                attachments.append(attachment)
                lock.unlock()
            }
        }
        
        let app = XCUIApplication(bundleIdentifier: "com.nianticlabs.pokemongo")
        
        var startupCount = 0
        var isStarted = false
        var lastStuck = false
        var isStartupCompleted = false
        var appStart = Date()
        
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        let coordStartup: XCUICoordinate
        let coordPassenger: XCUICoordinate
        let coordNearby: XCUICoordinate
        let coordRaids: XCUICoordinate
        let coordWeather1: XCUICoordinate
        let coordWeather2: XCUICoordinate
        let coordWarning: XCUICoordinate
        let compareStuck: (x: Int, y: Int)
        let compareStart: (x: Int, y: Int)
        let compareWeather: (x: Int, y: Int)
        let comparePassenger: (x: Int, y: Int)
        
        if app.frame.size.width == 375 { //iPhone Normal (6, 7, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 375, dy: 800))
            coordPassenger = normalized.withOffset(CGVector(dx: 275, dy: 950))
            coordNearby = normalized.withOffset(CGVector(dx: 600, dy: 1200))
            coordRaids = normalized.withOffset(CGVector(dx: 550, dy: 450))
            coordWeather1 = normalized.withOffset(CGVector(dx: 225, dy: 1145))
            coordWeather2 = normalized.withOffset(CGVector(dx: 225, dy: 1270))
            coordWarning = normalized.withOffset(CGVector(dx: 375, dy: 1125))
            compareStuck = (50, 1200)
            compareStart = (375, 800)
            compareWeather = (375, 916)
            comparePassenger = (275, 950)
        } else if app.frame.size.width == 768 { //iPad 9,7 (Air, Air2, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 768, dy: 1234))
            coordPassenger = normalized.withOffset(CGVector(dx: 768, dy: 1567))
            coordNearby = normalized.withOffset(CGVector(dx: 1387, dy: 1873))
            coordRaids = normalized.withOffset(CGVector(dx: 1124, dy: 120))
            coordWeather1 = normalized.withOffset(CGVector(dx: 1300, dy: 1700))
            coordWeather2 = normalized.withOffset(CGVector(dx: 768, dy: 2000))
            coordWarning = normalized.withOffset(CGVector(dx: 768, dy: 1700))
            compareStuck = (102, 1873)
            compareStart = (768, 1234)
            compareWeather = (768, 1360)
            comparePassenger = (768, 1567)
        } else if app.frame.size.width == 320 { //iPhone Small (5S, SE, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 320, dy: 655))
            coordPassenger = normalized.withOffset(CGVector(dx: 230, dy: 790))
            coordNearby = normalized.withOffset(CGVector(dx: 550, dy: 1040))
            coordRaids = normalized.withOffset(CGVector(dx: 470, dy: 335))
            coordWeather1 = normalized.withOffset(CGVector(dx: 240, dy: 975))
            coordWeather2 = normalized.withOffset(CGVector(dx: 220, dy: 1080))
            coordWarning = normalized.withOffset(CGVector(dx: 320, dy: 960))
            compareStuck = (42, 1040)
            compareStart = (320, 655)
            compareWeather = (320, 780)
            comparePassenger = (230, 790)
        } else if app.frame.size.width == 414 { //iPhone Large (6+, 7+, ...)
            coordStartup = normalized.withOffset(CGVector(dx: 621, dy: 1275))
            coordPassenger = normalized.withOffset(CGVector(dx: 820, dy: 1540))
            coordNearby = normalized.withOffset(CGVector(dx: 1060, dy: 2020))
            coordRaids = normalized.withOffset(CGVector(dx: 880, dy: 655))
            coordWeather1 = normalized.withOffset(CGVector(dx: 621, dy: 1890))
            coordWeather2 = normalized.withOffset(CGVector(dx: 621, dy: 2161))
            coordWarning = normalized.withOffset(CGVector(dx: 621, dy: 1865))
            compareStuck = (55, 2020)
            compareStart = (621, 1275)
            compareWeather = (621, 1512)
            comparePassenger = (820, 1540)
        } else {
            print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
            XCTFail()
            return
        }
        
        while true {
            
            if Date().timeIntervalSince(appStart) >= restartDelay {
                print("[DEBUG] Restarting Pokemon Go")
                app.terminate()
            }
            
            if app.state == .notRunning {
                startupCount = 0
                isStarted = false
                lastStuck = false
                isStartupCompleted = false
                appStart = Date()
                app.activate()
                sleep(1)
            }
            else if app.state != .runningForeground {
                app.activate()
                sleep(1)
            }
            
            if isStarted {
                if !isStartupCompleted {
                    print("[DEBUG] Performing Startup sequence")
                    coordStartup.tap()
                    sleep(2)
                    coordWarning.tap()
                    sleep(2)
                    coordWeather1.tap()
                    sleep(2)
                    coordWeather2.tap()
                    sleep(2)
                    coordNearby.tap()
                    sleep(2)
                    for _ in 0...5 {
                        _ = clickPassengerWarning(coord: coordPassenger, compare: comparePassenger)
                        coordNearby.tap()
                        usleep(1000)
                    }
                    sleep(2)
                    if !pokemon {
                        for _ in 0...20 {
                            if app.state == .runningForeground {
                                _ = clickPassengerWarning(coord: coordPassenger, compare: comparePassenger)
                                coordRaids.tap()
                                usleep(1000)
                            }
                        }
                    }
                    isStartupCompleted = true
                } else {
                    print("[DEBUG] App is running")
                    var screenshot = XCUIScreen.main.screenshot()
                    screenshot = clickPassengerWarning(coord: coordPassenger, compare: comparePassenger, screenshot: screenshot)
                    if compareWeather.x != 0 && compareWeather.y != 0 {
                        let color = screenshot.image.getPixelColor(pos: CGPoint(x: compareWeather.x, y: compareWeather.y))
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        if red > 0.235 && red < 0.353 && green > 0.353 && green < 0.47 && blue > 0.5 && blue < 0.63 {
                            print("[DEBUG] Clicking Weather Warning")
                            coordWeather1.tap()
                            sleep(2)
                            coordWeather2.tap()
                            sleep(2)
                            screenshot = XCUIScreen.main.screenshot()
                            screenshot = clickPassengerWarning(coord: coordPassenger, compare: comparePassenger, screenshot: screenshot)
                        }
                    }
                    if compareStuck.x != 0 && compareStuck.y != 0 {
                        let color = screenshot.image.getPixelColor(pos: CGPoint(x: compareStuck.x, y: compareStuck.y))
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        if red < 0.9 || green < 0.9 || blue < 0.9 {
                            if lastStuck {
                                print("[DEBUG] We are stuck somewhere. Restarting...")
                                app.terminate()
                                continue
                            } else {
                                lastStuck = true
                            }
                        } else {
                            lastStuck = false
                        }
                    }
                    sleep(2)
                }
            } else {
                let screenshotComp = XCUIScreen.main.screenshot()
                if compareStart.x != 0 && compareStart.y != 0 {
                    let color = screenshotComp.image.getPixelColor(pos: CGPoint(x: compareStart.x, y: compareStart.y))
                    var red: CGFloat = 0
                    var green: CGFloat = 0
                    var blue: CGFloat = 0
                    var alpha: CGFloat = 0
                    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    if (green > 0.75 && green < 0.9 && blue > 0.55 && blue < 0.7) {
                        print("[DEBUG] App Started")
                        isStarted = true
                    } else {
                        print("[DEBUG] App still in Startup")
                        if startupCount == 45 {
                            app.terminate() // Retry
                        }
                        startupCount += 1
                        sleep(1)
                    }
                } else {
                    fatalError("compareStart not set")
                }
            }
            
            lock.lock()
            while attachments.count > 0 {
                let attachment = attachments.removeLast()
                self.add(attachment)
            }
            lock.unlock()
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
            print("[DEBUG] Unsupported iOS modell. Please report this in our Discord!")
            XCTFail()
            return
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

    func clickPassengerWarning(coord: XCUICoordinate, compare: (x: Int, y: Int), screenshot: XCUIScreenshot?=nil) -> XCUIScreenshot {
        var shouldClick = false
        let screenshotComp = screenshot ?? XCUIScreen.main.screenshot()
        if compare.x != 0 && compare.y != 0 {
            let color = screenshotComp.image.getPixelColor(pos: CGPoint(x: compare.x, y: compare.y))
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            if (green > 0.75 && green < 0.9 && blue > 0.55 && blue < 0.7) {
                shouldClick = true
            }
        } else {
            shouldClick = true
        }
        if shouldClick {
            coord.tap()
            sleep(1)
        }
        if screenshot != nil {
            return XCUIScreen.main.screenshot()
        }
        else {
            return screenshotComp
        }
    }
    
}
