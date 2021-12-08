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

//MARK: take a look at this
//We want the identity of the item to be tied to the user but not the count
extension UserCount: Hashable { }




