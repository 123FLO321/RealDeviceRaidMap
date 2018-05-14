//
//  Raid.swift
//  COpenSSL
//
//  Created  on 01.05.18.
//

import PerfectLib
import PerfectMySQL

struct Raid {
    
    var id: Int?
    var gymId: Int
    var level: Int
    var pokemonId: Int?
    var timeSpawn: Int
    var timeBattle: Int
    var timeEnd: Int
    
    // cp move_1 move_2
    
    static func fromDB(gymId: Int) -> Raid? {
        guard let mysql = DB.mysql else {
            return nil
        }
        
        
        let sql = """
        SELECT id, fort_id, level, pokemon_id, time_spawn, time_battle, time_end
        FROM raids
        WHERE fort_id = "\(gymId)"
        ORDER BY time_spawn DESC
        LIMIT 1
        """
        
        guard mysql.query(statement: sql) else {
            return nil
        }
        let result = mysql.storeResults()
        if result != nil {
            let element = result!.next()
            if element != nil {
                let id = Int(element![0] ?? "") ?? 0
                let gymId = Int(element![1] ?? "") ?? 0
                let level = Int(element![2] ?? "") ?? 0
                let pokemonId = Int(element![3] ?? "")
                let timeSpawn = Int(element![4] ?? "") ?? 0
                let timeBattle = Int(element![5] ?? "") ?? 0
                let timeEnd = Int(element![6] ?? "") ?? 0

                return Raid(id: id, gymId: gymId, level: level, pokemonId: pokemonId, timeSpawn: timeSpawn, timeBattle: timeBattle, timeEnd: timeEnd)
            }
        }
        return nil
    }
    
    func save() -> Bool {
        guard let mysql = DB.mysql else {
            return false
        }
        
        let sqlLastMod = """
        SELECT MAX(last_modified) FROM fort_sightings fs2 WHERE fs2.fort_id=\(gymId)
        """
        
        guard mysql.query(statement: sqlLastMod) else {
            return false
        }
        let lastModified: Int
        
        let resultLastMod = mysql.storeResults()
        if resultLastMod != nil {
            let element = resultLastMod!.next()
            if element != nil {
                lastModified = Int(element![0] ?? "") ?? 0
            }
            else {
                return false
            }
        } else {
            return false
        }
        
        let sqlUpdate = """
        UPDATE fort_sightings
        SET updated = UNIX_TIMESTAMP()
        WHERE fort_id = \(gymId)
        AND last_modified = \(lastModified)
        """
        
        guard mysql.query(statement: sqlUpdate) else {
            return false
        }
        
        let sql = """
        INSERT INTO raids (id, fort_id, level, pokemon_id, time_spawn, time_battle, time_end)
        VALUES ("\(id.dbString)", "\(gymId)", "\(level)", \(pokemonId.dbString), \(timeSpawn), \(timeBattle), \(timeEnd))
        ON DUPLICATE KEY UPDATE
            fort_id=VALUES(fort_id),
            pokemon_id=VALUES(pokemon_id),
            time_spawn=VALUES(time_spawn),
            time_battle=VALUES(time_battle),
            time_end=VALUES(time_end)
        """
        
        guard mysql.query(statement: sql) else {
            return false
        }
        return true
    }
    
    
}
