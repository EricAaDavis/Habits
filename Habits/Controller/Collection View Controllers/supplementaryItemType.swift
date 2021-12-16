//
//  supplementaryItemType.swift
//  Habits
//
//  Created by Eric Davis on 15/12/2021.
//

import UIKit

enum SupplementaryItemType {
    case collectionSupplementaryView
    case layoutDecorationView
}

protocol SupplementaryItem {
    //The view class associated type enables me to register a class whose type is not known.
    associatedtype ViewClass: UICollectionReusableView
    
    var itemType: SupplementaryItemType { get }
    
    var reuseIdentifier: String { get }
    var viewKind: String { get }
    var viewClass: ViewClass.Type { get }
}

extension SupplementaryItem {
    func register(on collectionView: UICollectionView) {
        switch itemType {
        case .collectionSupplementaryView:
            collectionView.register(viewClass.self, forSupplementaryViewOfKind: viewKind, withReuseIdentifier: reuseIdentifier)
            
        case .layoutDecorationView:
            collectionView.collectionViewLayout.register(ViewClass.self, forDecorationViewOfKind: viewKind)
        }
    }
}

