//
//  UserCount.swift
//  Habits
//
//  Created by Eric Davis on 07/12/2021.
//

import Foundation


struct UserCount {
    let user: User
    let count: Int
}

extension UserCount: Codable { }

extension UserCount: Hashable { }



