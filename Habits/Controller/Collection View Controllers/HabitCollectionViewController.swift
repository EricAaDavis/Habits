//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

private let reuseIdentifier = "Cell"
private let sectionHeaderKind = "SectionHeader"
private let sectionHeaderIdentifier = "HeaderView"

let favoriteHabitColor = UIColor(hue: 0.15, saturation: 1, brightness: 0.9, alpha: 1)

class HabitCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: sectionHeaderKind, withReuseIdentifier: sectionHeaderIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    //MARK: I need better understanding of MVVM (Model-View-View Model)
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    //This enum encapsulates everything the collection view needs to display its data
    enum ViewModel {
        //This needs some explenation
        enum Section: Hashable, Comparable {
            
            var sectionColor: UIColor {
                switch self {
                case .favorites:
                    return favoriteHabitColor
                case .category(let category):
                    return category.color.uiColor
                }
            }
            
            //favorites will be displayed at the top
            case favorites
            case category(_ category: Category)
            
            //How is this sorting working
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs){
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                }
            }
        }
        //since there is no meaningfull distingtion between the view model and the model itself, i'll use a typealias
        typealias Item = Habit
    }
    
    //Isn't strictly necessaryt, but it's useful as an explicit reference to the seperation of the model from the view model
    struct Model {
        var habitsByName = [String: Habit]()
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    }
    
    //This is declared as i have done in prior lessons. By typealiasing the data source type, its made this decleration concise
    var dataSource: DataSourceType!
    //Model property to store the data model after it's fetched from the network.
    var model = Model()
    
    func update() {
        HabitRequest().sendFileRequest { result in
            print("The closure habitRequest was excecuted")
            switch result {
            case .success(let habits):
                self.model.habitsByName = habits
                //print(self.model.habitsByName)
//                print("These are the Habts: \(habits)")
            case .failure(let error):
                print(error)
                self.model.habitsByName = [:]
            }
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
//
        }
        print(model.habitsByName)
    }
    
    //I need to review this so that i fully understand it
    func updateCollectionView() {
        //first build a dictionary that maps each section to its associated array of items
        var itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            let item = habit
            let section: ViewModel.Section
            
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else {
                section = .category(habit.category)
            }
            
            partial[section, default: []].append(item)
        }
        //print(itemsBySection)
        itemsBySection = itemsBySection.mapValues({ $0.sorted() })
        let sectionIDs = itemsBySection.keys.sorted()

        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    //deque and set up PrimarySecondaryTextCollectionViewCells according to the contents of the view model item from the snapshot
    func configureCell(_ cell: PrimarySecondaryTextCollectionViewCell, withItem item: HabitCollectionViewController.ViewModel.Item) {
        cell.primaryTextLabel.text = item.name
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Habit", for: indexPath) as! PrimarySecondaryTextCollectionViewCell
            self.configureCell(cell, withItem: item)
            return cell
            
            
            }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, IndexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: sectionHeaderKind, withReuseIdentifier: sectionHeaderIdentifier, for: IndexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[IndexPath.section]
            switch section {
            case .favorites:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }
//            header.layer.cornerRadius = 10
            header.backgroundColor = section.sectionColor
            return header
        }
        return dataSource
    }
     
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        //create header layout
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: sectionHeaderKind, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    //This is a delegate method
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: self.model.favoriteHabits.contains(item) ? "Unfavorite" : "Favorite") { (action) in
                Settings.shared.toggleFavorite(item)
                self.updateCollectionView()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        return config
    }
    
    @IBSegueAction func showDetailedView(_ coder: NSCoder, sender: UICollectionViewCell?) -> HabitDetailedViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else {
                  return nil
              }
        return HabitDetailedViewController(coder: coder, habit: item)
    }
}
