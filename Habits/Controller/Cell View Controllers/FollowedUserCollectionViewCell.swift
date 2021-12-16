//
//  FollowedUserCollectionViewCell.swift
//  Habits
//
//  Created by Eric Davis on 15/12/2021.
//

import UIKit

class FollowedUserCollectionViewCell: PrimarySecondaryTextCollectionViewCell {
    @IBOutlet var seperatorLineView: UIView!
    @IBOutlet var seperatorLineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        seperatorLineHeightConstraint.constant = 1 / UITraitCollection.current.displayScale
    }
}


















