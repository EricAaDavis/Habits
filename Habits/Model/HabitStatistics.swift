//
//  HabitStatistics.swift
//  Habits
//
//  Created by Eric Davis on 07/12/2021.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

extension HabitStatistics: Codable { }




