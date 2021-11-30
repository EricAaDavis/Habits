//
//  Color.swift
//  Habits
//
//  Created by Eric Davis on 30/11/2021.
//

import Foundation

struct Color {
    let hue: Double
    let saturation: Double
    let brightness: Double
}


extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case hue = "h"
        case saturation = "s"
        case brightness = "b"
    }
}

