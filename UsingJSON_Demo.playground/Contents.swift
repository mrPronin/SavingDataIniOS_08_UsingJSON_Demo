import UIKit

class VideoGame: CustomStringConvertible {
    var name = ""
    var genre = ""
    var rating = 0
    var synopsis = ""
    var description: String {
        return "name: \(name), genre: \(genre), rating: \(rating), synopsis: \(synopsis)"
    }
}

class GameParser: NSObject {
    var xmlParser: NSXMLParser?
    var games: [VideoGame] = []
    var xmlText = ""
    var currentGame: VideoGame?
    
    init(withXML xml: String) {
        if let data = xml.dataUsingEncoding(NSUTF8StringEncoding) {
            xmlParser = NSXMLParser(data: data)
        }
    }
    
    func parse() -> [VideoGame] {
        xmlParser?.delegate = self
        xmlParser?.parse()
        return games
    }
}

extension GameParser: NSXMLParserDelegate {
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        xmlText = ""
        if elementName == "video_game" {
            currentGame = VideoGame()
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" {
            currentGame?.name = xmlText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        if elementName == "genre" {
            currentGame?.genre = xmlText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        if elementName == "synopsis" {
            currentGame?.synopsis = xmlText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        if elementName == "rating" {
            if let rating = Int(xmlText) {
                currentGame?.rating = rating
            }
        }
        if elementName == "video_game" {
            if let game = currentGame {
                games.append(game)
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        xmlText += string
    }
}

do {
    if let xmlURL = NSBundle.mainBundle().URLForResource("video_games", withExtension: "xml") {
        let xml = try String(contentsOfURL: xmlURL)
        let gameParser = GameParser(withXML: xml)
        let games = gameParser.parse()
        
        var topLevel: [AnyObject] = []
        for game in games {
            var gameDict: [String : AnyObject] = [:]
            gameDict["name"] = game.name
            gameDict["genre"] = game.genre
            gameDict["rating"] = NSNumber(integer: game.rating)
            gameDict["synopsis"] = game.synopsis
            topLevel.append(gameDict)
        }
        let jsonData = try NSJSONSerialization.dataWithJSONObject(topLevel, options: .PrettyPrinted)
        let fileManager = NSFileManager.defaultManager()
        let url = try fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let jsonURL = url.URLByAppendingPathComponent("video_games.json")
        print(jsonURL)
        jsonData.writeToURL(jsonURL, atomically: true)
    }
} catch {
    print("error: \(error)")
}
