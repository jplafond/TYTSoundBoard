//
//  Constants.swift
//  TYTSoundboard
//
//  Created by Jp LaFond on 8/8/17.
//  Copyright © 2017 Jp LaFond. All rights reserved.
//

import Foundation
import UIKit

struct Const {
    struct Clip {
        struct Base {
            static let name = "Animals R Innocent"
            static let data: Data? = {
                guard let urlPath = Bundle.main.path(forResource: "Animals R Inno~",
                                                     ofType: "mp3") else
                {
                    print("Can't generate a path for the base file")
                    return nil
                }
                let url = URL(fileURLWithPath: urlPath)
                var data: Data?
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    print("Unable to read: <\(error)>")
                    return nil
                }

                return data
            }()
        }
    }
}
