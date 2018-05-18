//
//  Gym.swift
//  Raid-Map
//
//  Created  on 02.05.18.
//

import PerfectMySQL

struct Gym {
    
    var id: Int32
    var name: String?
    var url: String?
    
    static func search(term: String) -> [Gym]? {
        guard let mysql = DB.mysql else {
            return nil
        }        
        
        let sql = """
        SELECT id, name, url
        FROM forts
        WHERE LOWER(name) LIKE ?
        LIMIT 10
        """
        
        let stmt = MySQLStmt(mysql)
        _ = stmt.prepare(statement: sql)
        stmt.bindParam("%\(term.lowercased())%")
        
        guard stmt.execute() else {
            return nil
        }
        
        var gyms = [Gym]()
        let result = stmt.results()
        while let element = result.next() {
            print(element)
            let id = element[0] as! Int32
            let name = element[1] as! String
            let url = element[2] as! String

            gyms.append(Gym(id: id, name: name, url: url))
        }
        return gyms
    }
    
}
