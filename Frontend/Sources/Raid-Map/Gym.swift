//
//  Gym.swift
//  Raid-Map
//
//  Created  on 02.05.18.
//

import PerfectMySQL

struct Gym {
    
    var id: Int
    var name: String?
    var url: String?
    
    static func search(term: String) -> [Gym]? {
        guard let mysql = DB.mysql else {
            return nil
        }        
        
        let sql = """
        SELECT id, name, url
        FROM forts
        WHERE LOWER(name) LIKE LOWER("%\(term)%")
        LIMIT 10
        """
        
        guard mysql.query(statement: sql) else {
            return nil
        }
        var gyms = [Gym]()
        let result = mysql.storeResults()
        if result != nil {
            while let element = result!.next() {
                let id = Int(element[0] ?? "") ?? 0
                let name = element[1]
                let url = element[2]

                gyms.append(Gym(id: id, name: name, url: url))
            }
        }
        return gyms
    }
    
}
