//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class HabitCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    //MARK: I need better understanding of MVVM (Model-View-View Model)
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    //This enum encapsulates everything the collection view needs to display its data
    enum ViewModel {
        //This needs some explenation
        enum Section: Hashable {
            //favorites will be displayed at the top
            case favorites
            case category(_ category: Category)
        }
        
        //since there is no meaningfull distingtion between the view model and the model itself, i'll use a typealias
        typealias Item = Habit
    }
    
    //Isn't strictly necessaryt, but it's useful as an explicit reference to the seperation of the model from the view model
    struct Model {
        var habitsByName = [String: Habit]()
    }
    
    //This is declared as i have done in prior lessons. By typealiasing the data source type, its made this decleration concise
    var dataSource: DataSourceType!
    //Model property to store the data model after it's fetched from the network.
    var model = Model()
    
    func update() {
        //Why don't i need to declare HabitRequest?
        HabitRequest().send { result in
            switch result {
            case .success(let habits):
                self.model.habitsByName = habits
                print("These are the Habts: \(habits)")
            case .failure(let error):
                print(error)
                self.model.habitsByName = [:]
            }
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        
    }
    
}
