//
//  MainRequestHandler.swift
//  COpenSSL
//
//  Created  on 20.04.18.
//

import PerfectLib
import PerfectHTTP
import PerfectMustache
import PerfectSessionMySQL
import SwiftRandom

struct MainRequestHandler {
    
    enum Page: String {
        case home = "index.mustache"
        case search = "search"
        case delete = "delete"
        case submit = "submit"
    }
    
    static func handle(request: HTTPRequest, response: HTTPResponse, page: Page, requiresLogin: Bool = false, requiresVerified: Bool = false) {
    
        var data = MustacheEvaluationContext.MapType()
        
        if page == .submit {
            var id = request.param(name: "id") ?? ""
            id.removeLast()
            let mon = Int32(request.param(name: "mon") ?? "")
            let gym = Int32(request.param(name: "gym") ?? "")
            let raidImage = RaidImage(hash: id, gymId: gym, pokemonId: mon)
            if !raidImage.save() {
                response.status = .internalServerError
                response.completed()
                return
            }
        }
        
        if page == .delete || page == .submit{
            let id = request.param(name: "id")
            if id == nil {
                response.status = .notAcceptable
            } else {
                let file = File(Dir.workingDir.path + "/webroot/static/images/\(id!).png")
                if file.exists {
                    file.delete()
                } else {
                    response.status = .notAcceptable
                }
            }
            response.redirect(path: "/")
            response.completed()
            return
        }
        
        if page == .search {

            let action = request.param(name: "action") ?? ""
            let term = request.param(name: "term") ?? ""
            
            var jsonData = [[String: Any]]()
            if action == "pokemon" {
                var pokemon: [Int]
                if Int(term) != nil && Int(term)! >= 1 && Int(term)! <= 386 {
                    pokemon = [Int(term)!]
                } else {
                    pokemon = PokemonData.search(term: term)
                }
                for poke in pokemon {
                    jsonData.append(["name": PokemonData.pokemon[poke]!, "id": poke, "url": "/static/icons/pokemon/\(poke).svg"])
                }
                

            } else if action == "gym" {
                let gyms = Gym.search(term: term)
                if gyms != nil {
                    for gym in gyms! {
                        jsonData.append(["name": gym.name ?? "", "id": gym.id, "url": gym.url ?? ""])
                    }
                } else {
                    response.status = .internalServerError
                    response.completed()
                    return
                }
            }
            else {
                response.status = .notAcceptable
                response.completed()
                return
            }
 
            do {
                response.setHeader(.contentType, value: "text/json")
                try response.setBody(json: jsonData)
                response.completed()
                return
            } catch {
                response.status = .internalServerError
                response.completed()
                return
            }
            

        }
        
        if page == .home {
            let imagesDir = Dir(Dir.workingDir.path + "/webroot/static/images/")
            var images = [String]()
            do {
                try imagesDir.forEachEntry { (name) in
                    if name.contains(".png") {
                        images.append(name)
                    }
                }
            } catch {}
            
            data["todo_count"] = images.count
            data["done_count"] = RaidImage.count()
            if images.count == 0 {
                data["error_no_image"] = true
            } else {
                var eggImages = [String]()
                for image in images {
                    if image.replacingOccurrences(of: ".png", with: "").last == "E" {
                        eggImages.append(image)
                    }
                }
                let image: String?
                if eggImages.count >= 5 {
                    image = eggImages.randomItem()
                } else {
                    image = images.randomItem()
                }
                
                let imageID = (image ?? "").replacingOccurrences(of: ".png", with: "")
                data["image"] = image
                data["id"] = imageID
                if imageID.last != nil {
                    data["show_pokemon"] = imageID.last! == "M"
                } else {
                    data["show_pokemon"] = true
                }
            }
        }
        
        response.setHeader(.contentType, value: "text/html")
        mustacheRequest(
            request: request,
            response: response,
            handler: MainPageHandler(page: page, data: data),
            templatePath: request.documentRoot + "/" + page.rawValue
        )
        response.completed()
    }
    
}
