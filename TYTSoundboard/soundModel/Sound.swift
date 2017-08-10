//
//  Sound.swift
//  TYTSoundboard
//
//  Created by Jp LaFond on 8/8/17.
//  Copyright © 2017 Jp LaFond. All rights reserved.
//

import Foundation

/// Sound clip to display/search/play
struct Sound {
    /// name of the file of the clip
    let name: String
    /// speaker in the clip, if known
    let speaker: String?
    /// text of the clip, if known
    let text: String?
    /// description of the clip
    let clipDescription: String?

    /// default initializer, which the failable initializer will need
    init(name: String,
         speaker: String? = nil,
         text: String? = nil,
         description: String? = nil) {
        self.name = name
        self.speaker = speaker
        self.text = text
        clipDescription = description
    }
}

// MARK: - Search functionality
extension Sound {
    /// Whether or not this sound clip contains the search string in any of the fields
    func shouldFilter(by search: String) -> Bool {
        let lowercasedSearch = search.lowercased()

        return name.lowercased().contains(lowercasedSearch) ||
            (speaker?.lowercased().contains(lowercasedSearch) ?? false) ||
            (text?.lowercased().contains(lowercasedSearch) ?? false) ||
            (clipDescription?.lowercased().contains(lowercasedSearch) ?? false)
    }
}

// MARK: - JSON functionality
extension Sound {
    /// Failable initializer which takes a JSON dictionary with known keys
    init?(json dict: Dictionary<String, String>) {
        guard let name = dict[Const.Sound.key.name] else
        {
            print("Missing expected key '\(Const.Sound.key.name)'")
            return nil
        }
        let speaker = dict[Const.Sound.key.speaker]
        let description = dict[Const.Sound.key.description]
        let text = dict[Const.Sound.key.text]

        self.init(name: name,
                  speaker: speaker,
                  text: text,
                  description: description)
    }

    // MARK: JSON Parsing
    /// Read the data from the file
    static func allClips(json fileName: String = Const.Sound.json.file) -> [Sound]? {
        guard let path = Bundle.main.path(forResource: fileName,
                                          ofType: Const.Sound.json.ext) else
        {
            print ("Unable to find <\(fileName)>")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch {
            print ("Unable to read from <\(fileName)>: " +
                "<\(error)>")
        }
        if let data = data {
            return allClips(data: data)
        }
        return nil
    }

    /// Parse the data into JSON
    static func allClips(data: Data) -> [Sound]? {
        do {
            if let jsonFullDict =
            try JSONSerialization.jsonObject(with: data,
            options: .allowFragments)
                as? Dictionary<String, Any>,
                let jsonArray = jsonFullDict[Const.Sound.key.sounds] as? Array<Dictionary<String,String>> {
                return allClips(json: jsonArray)
            }
        } catch {
            print("Unable to parse <\(error)>")
        }
        return nil
    }

    /// Parse the json array into a sound array 
    static func allClips(json array: Array<Dictionary<String, String>>) -> [Sound]? {
        var tmpArray = [Sound]()

        array.forEach {
            jsonDict in

            if let sound = Sound(json: jsonDict) {
                tmpArray.append(sound)
            }
        }

        if tmpArray.isEmpty {
            return nil
        }

        return tmpArray
    }
}

// MARK: - Sound Specific Constants
extension Const {
    struct Sound {
        struct key {
            static let description = "description"
            static let name = "name"
            static let speaker = "speaker"
            static let text = "text"

            static let sounds = "sounds"
        }

        struct json {
            static let file = "TYTSoundBoardData"
            static let ext = "json"
        }
    }
}

