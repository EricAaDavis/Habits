//
//  CombinedStatistics.swift
//  Habits
//
//  Created by Eric Davis on 14/12/2021.
//

import Foundation

struct CombinedStatistics {
    let userStatistics: [UserStatistics]
    let habitStatistics: [HabitStatistics]
}

extension CombinedStatistics: Codable {  }

