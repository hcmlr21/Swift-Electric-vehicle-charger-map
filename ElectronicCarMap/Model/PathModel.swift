//
//  PathModel.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/16.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

struct PathAPIResponse: Codable {
    var route: Route
    
    struct Route: Codable {
        var traoptimal: [Traoptimal]
        
        struct Traoptimal: Codable {
            var path:[[Double]]
            
        }
    }
}
