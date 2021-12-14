//
//  HomeCollectionViewController.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UICollectionViewController {
    
    var updateTimer: Timer?
    
    static let formatter: NumberFormatter = {
        var f = NumberFormatter()
        f.numberStyle = .ordinal
        return f
    }()
    func ordinalString(from number: Int) -> String {
        return Self.formatter.string(from: NSNumber(integerLiteral: number + 1))!
    }
    
    override func viewDidLoad() {
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        updateUsersAndHabits()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.update()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>


    enum ViewModel {
        enum Section: Hashable {
            case leaderboard
            case followedUsers
        }

        enum Item: Hashable{
            case leaderboardHabit(name: String, leadingUserRanking: String?, secondaryUserRanking: String?)
            case followedUser(_ user: User, message: String)
            
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .leaderboardHabit(let name, _, _):
                    hasher.combine(name)
                case .followedUser(let User, _):
                    hasher.combine(User)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.leaderboardHabit(let lName, _, _), .leaderboardHabit(let rName, _, _)):
                    return lName == rName
                case (.followedUser(let lUser, _), .followedUser(let rUser, _)):
                    return lUser == rUser
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var usersByID = [String: User]()
        var habitsByName = [String: Habit]()
        var habitStatistics = [HabitStatistics]()
        var userStatistics = [UserStatistics]()
        
        var currentUser: User {
            return Settings.shared.currentUser
        }
        
        var users: [User] {
            return Array(usersByID.values)
        }
        
        var habits: [Habit] {
            return Array(habitsByName.values)
        }
        
        var followedUsers: [User] {
            return Array(usersByID.filter { Settings.shared.followedUserIDs.contains($0.key) }.values)
        }
        
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
        
        var nonFavoriteHabits: [Habit] {
            return habits.filter { !favoriteHabits.contains($0) }
        }
    }
    
    var model = Model()
    var dataSource: DataSourceType!
    
    func updateUsersAndHabits() {
        UserRequest().sendFileRequest { result in
            switch result {
            case .success(let users):
                self.model.usersByID = users
            case .failure:
                break
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
        
        HabitRequest().sendFileRequest { result in
            switch result {
            case .success(let habits):
                self.model.habitsByName = habits
            case .failure:
                break
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func update() {
        CombinedStatisticsRequest().sendFileRequest { result in
            switch result {
            case .success(let combinedStatistics):
                self.model.userStatistics = combinedStatistics.userStatistics
                self.model.habitStatistics = combinedStatistics.habitStatistics
            case .failure:
                self.model.userStatistics = []
                self.model.habitStatistics = []
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        
        //I need to understand filter(_:)
        //I need to understand sorted(by:)
        //I need to understand reduce(into:_:)
        //Filter the the habits statistics
        let leaderboardItems = model.habitStatistics.filter { statistics in
            //Eliminate habits that aren't in the users favorite
            return model.favoriteHabits.contains {
                $0.name == statistics.habit.name
            }
        }
        //Sort the habits by name
        .sorted{ $0.habit.name < $1.habit.name }
        //Reduce the resulting array into an array of view model items
        //What is partial?
        .reduce(into: [ViewModel.Item]()) { partial, statistics in
            // Rank the user counts form highest to lowest.
            let rankedUserCounts = statistics.userCounts.sorted { $0.count >
                $1.count
            }
            // Find the index of the current user's count, keeping in mind that it won't exist if the user hasn't logget that habit yet.
            let myCountIndex = rankedUserCounts.firstIndex {
                $0.user.id == self.model.currentUser.id }
            
            func userRankingString (from userCount: UserCount) -> String {
                var name = userCount.user.name
                var ranking = ""
                if userCount.user.id == self.model.currentUser.id {
                    name = "You"
                    ranking = " (\(ordinalString(from: myCountIndex!)))"
                }
                return "\(name) \(userCount.count)" + ranking

            }
            
            var leadingRanking: String?
            var secondaryRanking: String?
              
            // Examine the number of user counts for the statistics:
            switch rankedUserCounts.count {
            case 0:
                // If 0, set the leader label to "Nobody Yet!" and leave the secondary label 'nil'
                leadingRanking = "Nobody yet!"
            case 1:
                // If 1, set the leader label to the only user and count.
                let onlyCount = rankedUserCounts.first!
                leadingRanking = userRankingString(from: onlyCount)
            default:
                // Otherwise, do the following:
                // Set the leader label to the user at index 0.
                leadingRanking = userRankingString(from: rankedUserCounts[0])
                
                // Check wether the index of the current user's count exists and is not 0.
                if let myCountIndex = myCountIndex, myCountIndex != rankedUserCounts.startIndex {
                    // If true, the user's count and ranking should be displayed in the secondary label.
                    secondaryRanking = userRankingString(from: rankedUserCounts[myCountIndex])
                } else {
                    // If false, the second-place user count should be displayed.
                    secondaryRanking = userRankingString(from: rankedUserCounts[1])
                }
            }
            let leaderboardItem = ViewModel.Item.leaderboardHabit(name: statistics.habit.name, leadingUserRanking: leadingRanking, secondaryUserRanking: secondaryRanking)
            
            partial.append(leaderboardItem)
        }
        sectionIDs.append(.leaderboard)
        
        var itemsBySection = [ViewModel.Section.leaderboard: leaderboardItems]
        
        var followedUserItems = [ViewModel.Item]()
        
        func loggedHabitNames(for user: User) -> Set<String> {
            var names = [String]()
            
            if let stats = model.userStatistics.first(where: { $0.user == user }) {
                names = stats.habitCounts.map { $0.habit.name }
            }
            
            return Set(names)
        }
        
        // Get the current user's logged habits and extracte the favorites.
        let currentUserLoggedHabits = loggedHabitNames(for: model.currentUser)
        let favoriteLoggedHabits = Set(model.favoriteHabits.map
                                       {$0.name}).intersection(currentUserLoggedHabits)
                //The intersection method return a set with the shared elements in both sets.
        
        // Loop through all the followed users.
        for followedUser in model.followedUsers.sorted(by: { $0.name < $1.name }) {
            let message: String
            
            let followedUserLoggedHabits = loggedHabitNames(for: followedUser)
            
            // If the users have a habit in common:
            let commonLoggedHabits = followedUserLoggedHabits.intersection(currentUserLoggedHabits)
            if commonLoggedHabits.count > 0 {
                // Pick the habit to focus on.
                let habitName: String
                let commonFavoriteLoggedHabits = favoriteLoggedHabits.intersection(commonLoggedHabits)
                
                if commonFavoriteLoggedHabits.count > 0 {
                    //Why is it safe to unwrap this? - Because we wont reach this part unless we have a common favorite logged habit
                    habitName = commonFavoriteLoggedHabits.sorted().first!
                } else {
                    habitName = commonLoggedHabits.sorted().first!
                }
                
                // Get the full statistics (all the user counts) for that habit.
                let habitStats = model.habitStatistics.first { $0.habit.name == habitName }!
                
                // Get the ranking for each user.
                let rankedUserCounts = habitStats.userCounts.sorted { $0.count > $1.count }
                let currentUserRanking = rankedUserCounts.firstIndex { $0.user == model.currentUser }!
                let followedUserRanking = rankedUserCounts.firstIndex { $0.user == followedUser }!
        
                // Construct the message depending in who's leading.
                if currentUserRanking < followedUserRanking {
                    message = "Currently #\(ordinalString(from: followedUserRanking)), behind you (#\(ordinalString(from: currentUserRanking))) in \(habitName). \nSend them a friendly reminder!"
                } else if currentUserRanking > followedUserRanking {
                    message = "Currently #\(ordinalString(from: followedUserRanking)), ahead of you (#\(ordinalString(from: currentUserRanking))) in \(habitName). \nYou might catch up with a little extra effort!"
                } else {
                    message = "You're tied at \(ordinalString(from: followedUserRanking)) in \(habitName)! Now's your chance to pull ahead."
                }
            
            // Otherwise, if the followed user has logged at least one habit:
            } else if followedUserLoggedHabits.count > 0{
                // Get an arbitrary habit name.
                let habitName = followedUserLoggedHabits.sorted().first!
                
                // Get the full statistics (all the user counts) for that habit.
                let habitStats = model.habitStatistics.first { $0.habit.name == habitName }!
        
                // Get the user's ranking for that habit.
                let rankedUserCounts = habitStats.userCounts.sorted { $0.count > $1.count }
                let followedUserRanking = rankedUserCounts.firstIndex { $0.user == followedUser }!
                
                // Construct the message.
                message = "Currently #\(ordinalString(from: followedUserRanking)), in \(habitName). \nMaybe you should give this habit a look."
            
            // Otherwise, this user hasn't done anything.
            } else {
                message = "This user doesn't seem to have done much yet. Check in to see if they need any help getting started."
            }
            
            followedUserItems.append(.followedUser(followedUser, message: message))
        }
        
        sectionIDs.append(.followedUsers)
        itemsBySection[.followedUsers] = followedUserItems
        print("These are the items by section \(itemsBySection)")
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item {
            case .leaderboardHabit(let name, let leadingUserRanking, let secondaryUserRanking):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardHabit", for: indexPath) as! LeaderboardhabitCollectionViewCell
                
                cell.habitNameLabel.text = name
                cell.leaderBoardLabel.text = leadingUserRanking
                cell.secondaryLabel.text = secondaryUserRanking
                cell.backgroundColor = UIColor(hue: 0.5, saturation: 0.3, brightness: 0.4, alpha: 0.5)
                cell.layer.cornerRadius = 20
                return cell
            default:
                return nil
            }
        }
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .leaderboard:
                let leaderboardItemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.3)
                )
                let leaderboardItem = NSCollectionLayoutItem(layoutSize: leaderboardItemSize)
                
                let verticalTrioSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.75),
                    heightDimension: .fractionalWidth(0.75)
                )
                let leaderboardVerticalTrio = NSCollectionLayoutGroup.vertical(layoutSize: verticalTrioSize, subitem: leaderboardItem, count: 3)
                leaderboardVerticalTrio.interItemSpacing = .fixed(10)
                
                let leaderboardSection = NSCollectionLayoutSection(group: leaderboardVerticalTrio)
                leaderboardSection.interGroupSpacing = 20
                leaderboardSection.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 0,
                    trailing: 0)
                
                leaderboardSection.orthogonalScrollingBehavior = .continuous
                leaderboardSection.contentInsets = NSDirectionalEdgeInsets(
                    top: 12,
                    leading: 20,
                    bottom: 20,
                    trailing: 20)
                
                return leaderboardSection
            default:
                return nil
            }
        }
        return layout
    }
    
    
}

