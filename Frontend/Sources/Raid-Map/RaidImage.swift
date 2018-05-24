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
    var gymId: Int32?
    var pokemonId: Int32?
    
    static func fromDB(hash: String) -> RaidImage? {
        guard let mysql = DB.mysql else {
            return nil
        }
        let sql = """
        SELECT hash, gym_id, pokemon_id
        FROM raid_images
        WHERE hash = ?
        LIMIT 1
        """
        
        let stmt = MySQLStmt(mysql)
        _ = stmt.prepare(statement: sql)
        stmt.bindParam(hash)

        guard stmt.execute() else {
            return nil
        }
        
        let result = stmt.results()
        guard let element = result.next() else {
            return nil
        }
        let hash = element[0] as! String
        let gymId = element[1] as? Int32
        let pokemonId = element[2] as? Int32
        return RaidImage(hash: hash, gymId: gymId, pokemonId: pokemonId)
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
                let gymId = Int32(element[1] ?? "")
                let pokemonId = Int32(element[2] ?? "")
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
        WHERE hash = ?
        """
        
        let stmt = MySQLStmt(mysql)
        _ = stmt.prepare(statement: sql)
        stmt.bindParam(hash)
        
        return stmt.execute()
    }
    
    func save() -> Bool {
        guard let mysql = DB.mysql else {
            return false
        }
            
        let sql = """
        INSERT INTO raid_images (hash, gym_id, pokemon_id)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE
            gym_id=VALUES(gym_id),
            pokemon_id=VALUES(pokemon_id)
        """
        
        let stmt = MySQLStmt(mysql)
        _ = stmt.prepare(statement: sql)
        stmt.bindParam(hash)
        if gymId != nil {
            stmt.bindParam(gymId!)
        } else {
            stmt.bindParam()
        }
        if pokemonId != nil {
            stmt.bindParam(pokemonId!)
        } else {
            stmt.bindParam()
        }
        
        return stmt.execute()
    }
    
}
