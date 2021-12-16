//
//  Color.swift
//  Habits
//
//  Created by Eric Davis on 30/11/2021.
//

import UIKit

struct Color: Equatable {
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

extension Color {
    var uiColor: UIColor {
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1)
    }
}

extension Color: Hashable {  }
