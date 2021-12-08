//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

class UserCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }


    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
//    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
//    var dataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

    enum ViewModel {
        typealias Section = Int

        struct Item: Hashable {
            let user: User
            let isFollowed: Bool

            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }

            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }

    struct Model {
        var usersByID = [String: User]()
        var followedUsers: [User] {
            return Array(usersByID.filter
            { Settings.shared.followedUserIDs.contains($0.key)
            }.values)
        }
    }
    //why isn't it = instead of :?
    var dataSource: DataSourceType!
    var model = Model()

    func update() {
        UserRequest().sendFileRequest { result in
            switch result {
            case .success(let users):
                self.model.usersByID = users
            case .failure(let error):
                print("The request failed for the user request")
                print(error)
                self.model.usersByID = [:]
            }

            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }

    func updateCollectionView() {
        let users = model.usersByID.values.sorted().reduce(into: [ViewModel.Item]()) { partial, user in
            partial.append(ViewModel.Item(user: user, isFollowed: model.followedUsers.contains(user)))
        }
        let _ = users

        let itemsBySection = [0: users]

        guard let dataSource = dataSource else {
            print("The data source is nil")
            return
        }
        //This failed because i didn't create the dataSource, that is why it was nil.
        dataSource.applySnapshotUsing(sectionIDs: [0], itemsBySection: itemsBySection )

    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "User", for: indexPath) as! PrimarySecondaryTextCollectionViewCell
            
            cell.primaryTextLabel.text = item.user.name
            cell.backgroundColor = .green
            cell.layer.cornerRadius = 20
            
            return cell
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBSegueAction func showUserDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> UserDetailedViewController? {
        
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else {
                  return nil
              }
        
        return UserDetailedViewController(coder: coder, user: item.user)
    }
}
