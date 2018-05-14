//
//  InputManager.swift
//  Raid-Map
//
//  Created  on 01.05.18.
//

import Foundation
import PerfectLib
import PerfectThread

class InputManager {
    
    private static let importDir = Dir(Dir.workingDir.path + "/inbox")
    
    private init() {
        
    }
    
    public static func start() {
        Threading.dispatch {
            while true {
                do {
                    try run()
                } catch {
                    Log.error(message: "InputManager failed with error: \(error.localizedDescription)")
                }
                sleep(1)
            }
        }
    }
    
    private static func run() throws {
        try importDir.forEachEntry { (name) in
            if name.first != nil && name.first! != "." && name.last != nil && name.last == "/" {
                let dir = Dir(importDir.path + "/" + name)
                var full: File?
                var mon: File?
                var monHash: String?
                var time: Int?
                var level: Int?
                try dir.forEachEntry(closure: { (name) in
                    if name == "Full.png" {
                        full = File(dir.path + "/" + name)
                    }
                    else if name == "time.txt" {
                        let file = File(dir.path + "/" + name)
                        let string = try file.readString()
                            .replacingOccurrences(of: "~", with: "")
                            .replacingOccurrences(of: "-", with: "")
                            .replacingOccurrences(of: "\n", with: "")
                        let stringComp = string.components(separatedBy: ":")
                        if stringComp.count == 2 {
                            let hour = Int(stringComp[0]) ?? 0
                            let minute = Int(stringComp[1]) ?? 0
                            time = hour * 3600 + minute * 60
                        } else if string.contains(string: "Raid") {
                            time = -1
                        }
                    } else if name == "level.txt" {
                        let file = File(dir.path + "/" + name)
                        let string = try file.readString()
                        
                        // @ and M = 1 level
                        let result = string.trimmingCharacters(in: CharacterSet(charactersIn: "@M").inverted)
                        level = result.count

                        // fig = 2 level
                        let tok =  string.components(separatedBy:"ﬁg")
                        level! += (tok.count-1)*2
                        
                        if level! < 1 {
                            level = 1
                        } else if level! > 5 {
                            level = 5
                        }
                        
                    }
                    else if name.contains(string: ".png") {
                        mon = File(dir.path + "/" + name)
                        monHash = name.replacingOccurrences(of: ".png", with: "")
                    }
                })
                if full != nil && time != nil && mon != nil {
                    let raidImageMon = RaidImage.fromDB(hash: monHash!)
                    
                    if raidImageMon == nil {
                        do {
                            let add: String
                            if time == -1 {
                                add = "M"
                            } else {
                                add = "E"
                            }
                            try full!.copyTo(path: Dir.workingDir.path + "/webroot/static/images/\(monHash!)\(add).png", overWrite: true)
                        } catch {}
                    }
                    
                    if raidImageMon != nil && time != nil && Date(timeIntervalSince1970: TimeInterval(full!.modificationTime)).timeIntervalSinceNow >= -1800 {
                        if raidImageMon!.gymId != nil && level != nil && level! >= 1 && level! <= 5 {
                        
                            if time != -1 && raidImageMon!.pokemonId == 0 {
                                
                                let timezoneSeconds = Int(ProcessInfo.processInfo.environment["TIMEZONE_SECONDS"] ?? "") ?? 0
                                let date = Date().setTime(hour: 0, min: 0, sec: 0, timeZone: TimeZone(secondsFromGMT: timezoneSeconds)!)!.addingTimeInterval(TimeInterval(time!))
                                
                                let dateBattle = Int(date.timeIntervalSince1970)
                                let dateStart = dateBattle - 3600
                                let dateEnd = dateBattle + 2700
                                let oldRaid = Raid.fromDB(gymId: raidImageMon!.gymId!)
                                if oldRaid != nil && oldRaid?.timeBattle == dateBattle {
                                    // We are good
                                } else {
                                    let raid = Raid(
                                        id: nil,
                                        gymId: raidImageMon!.gymId!,
                                        level: level!,
                                        pokemonId: raidImageMon!.pokemonId,
                                        timeSpawn: dateStart,
                                        timeBattle: dateBattle,
                                        timeEnd: dateEnd
                                    )
                                    if !raid.save() {
                                        Log.error(message: "Failed to save Raid")
                                        return
                                    }
                                }
                                
                            } else if time == -1 && raidImageMon!.pokemonId != nil {
                                var raid = Raid.fromDB(gymId: raidImageMon!.gymId!)
                                if raid != nil {
                                    raid!.pokemonId = raidImageMon!.pokemonId
                                    if !raid!.save() {
                                        Log.error(message: "Failed to save Raid")
                                        return
                                    }
                                }
                            }
                        }
                    }
                    try dir.forEachEntry(closure: { (name) in
                        File(dir.path + "/" + name).delete()
                    })
                    try dir.delete()
                    
                }
            }
        }
    }
    
}
