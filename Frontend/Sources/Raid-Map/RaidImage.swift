//
//  RaidStats.swift
//  COpenSSL
//
//  Created  on 01.05.18.
//

import PerfectLib
import PerfectMySQL

struct RaidImage {
    
    var hash: String
    var gymId: Int?
    var pokemonId: Int?
    
    static func fromDB(hash: String) -> RaidImage? {
        guard let mysql = DB.mysql else {
            return nil
        }
        let sql = """
        SELECT hash, gym_id, pokemon_id
        FROM raid_images
        WHERE hash = "\(hash)"
        LIMIT 1
        """
        
        guard mysql.query(statement: sql) else {
            return nil
        }
        let result = mysql.storeResults()
        if result != nil {
            let element = result!.next()
            if element != nil {
                let hash = element![0] ?? ""
                let gymId = Int(element![1] ?? "")
                let pokemonId = Int(element![2] ?? "")
                return RaidImage(hash: hash, gymId: gymId, pokemonId: pokemonId)
            }
        }
        return nil
    }
    
    static func fromDB() -> [RaidImage]? {
        guard let mysql = DB.mysql else {
            return nil
        }
        let sql = """
        SELECT hash, gym_id, pokemon_id
        FROM raid_images
        """
        
        guard mysql.query(statement: sql) else {
            return nil
        }
        let result = mysql.storeResults()
        var images = [RaidImage]()
        if result != nil {
            while let element = result!.next() {
                let hash = element[0] ?? ""
                let gymId = Int(element[1] ?? "")
                let pokemonId = Int(element[2] ?? "")
                images.append(RaidImage(hash: hash, gymId: gymId, pokemonId: pokemonId))
            }
        }
        return images
    }
    
    static func count() -> Int? {
        guard let mysql = DB.mysql else {
            return nil
        }
        let sql = """
        SELECT COUNT(*)
        FROM raid_images
        """
        
        guard mysql.query(statement: sql) else {
            return nil
        }
        let result = mysql.storeResults()
        if result != nil {
            let element = result!.next()
            if element != nil {
                return Int(element![0] ?? "")
            }
        }
        return nil
    }
    
    func delete() -> Bool {
        guard let mysql = DB.mysql else {
            return false
        }
        
        let sql = """
        DELETE FROM raid_images
        WHERE hash = "\(hash)"
        """
        
        guard mysql.query(statement: sql) else {
            return false
        }
        return true
    }
    
    func save() -> Bool {
        guard let mysql = DB.mysql else {
            return false
        }
            
        let sql = """
        INSERT INTO raid_images (hash, gym_id, pokemon_id)
        VALUES ("\(hash)", "\(gymId.dbString)", \(pokemonId.dbString))
        ON DUPLICATE KEY UPDATE
            gym_id=VALUES(gym_id),
            pokemon_id=VALUES(pokemon_id)
        """
        
        guard mysql.query(statement: sql) else {
            return false
        }
        return true
    }
    
}
