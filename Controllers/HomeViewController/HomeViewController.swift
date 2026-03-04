//
//  HomeViewController.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 04/04/24.
//

import Foundation
import UIKit
import FirebaseFirestoreInternal
import StoreKit
import GoogleMobileAds

class HomeViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var newsInfoLoading: Bool = true
    private var allPostsLoading: Bool = true
    private var myPostsLoading: Bool = true
    //MARK: Variables
    let PlusButton = UIButton(type: .custom)
    let collectionArray = ["Latest News","Cellar World","My Cellar"]
    let selectedIndex = 0
    let selectedNewsIndex: Int = -1
    var names:[String] = []
    var isAdShown: Bool = false
    var isDataLoaded = false
    var isBannerVisible = true
    private var allPosts:[AlcoholDetailsModel]?
    private var myPosts:[AlcoholDetailsModel]?
    private var newsHeadings:[String] = []
    
    let bannerViewHeight: CGFloat = 60
    // var isBannerVisible = true // Set this according to your condition
    // private var newsInfo:[NewsModel]?
    var newsInfo: [NewsModel] = []
    var allNewsInfo: [NewsModel] = []
    var allCellarInfo: [AlcoholDetailsModel] = []
    var allMyCellarInfo: [AlcoholDetailsModel] = []
    private var searchedPosts:[AlcoholDetailsModel]?
    private var interstitial: GADInterstitialAd?
    // var names:[String] = []
    
    //MARK: View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        let nib = UINib(nibName: "HomeViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeViewCell")
        
        let nibLoad = UINib(nibName: "LoadingViewCell", bundle: nil)
        tableView.register(nibLoad, forCellReuseIdentifier: "LoadingViewCell")
        
        tableView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        
        //        let nibBanner = UINib(nibName: "BannerTableViewCell", bundle: nil)
        //        tableView.register(nibBanner, forCellReuseIdentifier: "BannerTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        buttonSetup()
        if UserDefaults.standard.bool(forKey: "isUserSubscribed") == false {
            setUpBannerView()
        }
       
        ///Disable Sticky Header
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        tableView.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myCellarDeleted(_:)), name: NSNotification.Name(rawValue: "MyCellarDeleted"), object: nil)
        fetchData()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)  // Dismisses the keyboard for all text fields in the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeLabel.text = "Home".localized()
        setupFont()
        searchTextField.placeholder = "Search".localized()
        tableView.reloadData()
        if UserDefaults.standard.bool(forKey: "isUserSubscribed") == false {
        if isAdShown == false {
            setUpInterstitialAd { [weak self] in
                // This code block is executed once the ad is loaded
                self?.presentInterstitialIfReady()
            }
        }
    }
    }
    
    //MARK: Functions
    
    @IBAction func searchTextField(_ sender: Any) {
        if let char = searchTextField.text {
            let trimmedPrefix = char.trimmingCharacters(in: .whitespacesAndNewlines)
            if !char.isEmpty && !trimmedPrefix.isEmpty {
                newsInfo = filterNewsDetails(newsDetails: allNewsInfo, containing: trimmedPrefix)
                allPosts = filterAlcoholDetails(alcoholDetails: allCellarInfo, containing: trimmedPrefix)
                myPosts = filterAlcoholDetails(alcoholDetails: allMyCellarInfo, containing: trimmedPrefix)
              
            } else {
                newsInfo = allNewsInfo
                allPosts = allCellarInfo
                myPosts = allMyCellarInfo
            }
            tableView.reloadData()
        }
    }
    
    func filterNewsDetails(newsDetails: [NewsModel], containing prefix: String) -> [NewsModel] {
        let newsDetails = newsDetails.filter { detail in
            let lowercasePrefix = prefix.lowercased()
            let categoryMatches = detail.heading.lowercased().contains(lowercasePrefix) ?? false
            let subCategoryMatches = detail.description.lowercased().contains(lowercasePrefix) ?? false
            return categoryMatches || subCategoryMatches
        }
        return newsDetails
    }
    
    func filterAlcoholDetails(alcoholDetails: [AlcoholDetailsModel], containing prefix: String) -> [AlcoholDetailsModel] {
        let filteredDetails = alcoholDetails.filter { detail in
            let lowercasePrefix = prefix.lowercased()
            let categoryMatches = detail.category?.lowercased().contains(lowercasePrefix) ?? false
            let subCategoryMatches = detail.type?.lowercased().contains(lowercasePrefix) ?? false
            let nameMatches = detail.name?.lowercased().contains(lowercasePrefix) ?? false
            let makerMatches = detail.maker?.lowercased().contains(lowercasePrefix) ?? false
            let originMatches = detail.origin?.lowercased().contains(lowercasePrefix) ?? false
            let remarkMatches = detail.yourRemark?.lowercased().contains(lowercasePrefix) ?? false
            let reviewMatches = detail.yourReview?.lowercased().contains(lowercasePrefix) ?? false
            let shopMatches = detail.shopFrom?.lowercased().contains(lowercasePrefix) ?? false
    

            return nameMatches || makerMatches || originMatches || categoryMatches || subCategoryMatches || remarkMatches || reviewMatches || shopMatches
        }
        return filteredDetails
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        searchTextField.text = ""
        newsInfo = allNewsInfo
        allPosts = allCellarInfo
        myPosts = allMyCellarInfo
        
        tableView.reloadData()
    }
    
    func setUpBannerView() {
        let banner: GADBannerView = {
            let banner = GADBannerView()
            //banner.adUnitID = "ca-app-pub-3940256099942544/9214589741" //testing
            banner.adUnitID = "ca-app-pub-9990987621012540/1916913095" //live
            banner.backgroundColor =  UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
            banner.load(GADRequest())
            return banner
        }()
        
        banner.rootViewController = self
        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            banner.heightAnchor.constraint(equalToConstant: 50),
            banner.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        view.bringSubviewToFront(banner)
    }
    
//    func sendSelectedIndexNotification(index: Int, section: Int) {
//        
//        switch section {
//        case 0:
//            print("Section 0")
//        case 1:
//            print("Section 1")
//            UserDefaults.setValue(index , forKey: "allCellarSelectedIndex")
//            if let tabBarController = self.tabBarController as? HomeTabBarController {
//                tabBarController.selectedIndex = 1
//            }
//        case 2:
//            print("Section 2")
//            UserDefaults.setValue(index , forKey: "myCellarSelectedIndex")
//            if let tabBarController = self.tabBarController as? HomeTabBarController {
//                tabBarController.selectedIndex = 2
//            }
//        default:
//            return
//        }
//        
//        NotificationCenter.default.post(name: NSNotification.Name("SelectedIndexChangedNotificationForAllCellar"), object: nil, userInfo: ["selectedIndex": index])
//       
//    }
    
    func adjustTableViewContentInset() {
        var additionalInset: CGFloat = 0
        
        if isBannerVisible {
            additionalInset = bannerViewHeight
        }
        tableView.contentInset = UIEdgeInsets(top: additionalInset, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: additionalInset, left: 0, bottom: 0, right: 0)
    }
    
    
    func fetchData() {
        self.activityIndicator.startAnimating()
        let group = DispatchGroup()
        group.enter()
        fetchCellarWorlsData { success in
            defer { group.leave() }
            if !success {
                // self.showErrorAlert(message: "Failed to fetch cellar worlds data.")
            }
        }
        group.enter()
        fetchMyCellarData(email: UserDefaultsManager.getUserEmail() ?? "") { success in
            defer { group.leave() }
            if !success {
                // self.showErrorAlert(message: "Failed to fetch my cellar data.")
            }
        }
        group.enter()
        fetchNews { success in
            defer { group.leave() }
            if !success {
                // self.showErrorAlert(message: "Failed to fetch news.")
            }
        }
        group.notify(queue: .main) {
            // All tasks completed
            self.isDataLoaded = true
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    
    func fetchNews(completion: @escaping (Bool) -> Void ) {
        let db = Firestore.firestore()
        let newsCollection = db.collection("news")
        // Make a query to fetch news items
        newsCollection.getDocuments { (querySnapshot, error) in
            completion(true)
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                for document in documents {
                    let newsId = document.documentID
                    let newsData = document.data()
                    if let heading = newsData["heading"] as? String,
                       let description = newsData["description"] as? String,
                       let time = newsData["time"] as? Timestamp,
                       let imageUrl = newsData["imageUrl"] as? String {
                        self.newsHeadings.append(heading)
                        let news = NewsModel(id: newsId, heading: heading, description: description, time: time.dateValue(), imageUrl: imageUrl)
                        self.newsInfo.append(news)
                    }
                }
                self.allNewsInfo = self.newsInfo
                self.newsInfoLoading = false
            }
        }
    }
    func handleCellAction(forSection section: Int, atIndex index: Int) {
        print("Handling logic for Section 1 at index \(index)")
            
        if section == 1 {
            UserDefaults.standard.setValue(index, forKey: "allCellarSelectedIndex")
            
        } else if section == 2 {
            UserDefaults.standard.setValue(index, forKey: "myCellarSelectedIndex")
        }
        if let tabBarController = self.tabBarController as? HomeTabBarController {
            tabBarController.selectedIndex = section
        }
    }

    
    private func presentInterstitialIfReady() {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: self)
            self.isAdShown = true
        } else {
            print("Interstitial ad wasn't ready")
        }
    }
    
    func setUpInterstitialAd(completion: @escaping () -> Void) {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-9990987621012540/8106916926",
                               request: request,
                               completionHandler: { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            completion() // Call completion handler when the ad is loaded
        })
    }
    
    private func fetchCellarWorlsData(completion: @escaping (Bool) -> Void) {
        FetchDataFromFireBase.shared.fetchAllPosts { alcohols in
            for index in 0..<alcohols.count {
                self.names.append(alcohols[index].name ?? "")
            }
            self.allPosts = alcohols
            self.allCellarInfo = alcohols
            self.searchedPosts = alcohols
            self.allPostsLoading = false
            self.tableView.reloadData()
            completion(true)
            if self.searchedPosts?.count == 0 {
                // self.noPostsLabel.isHidden = false
            } else {
                //self.noPostsLabel.isHidden = true
            }
        }
    }
    
    private func fetchMyCellarData(email: String, completion: @escaping (Bool) -> Void) {
        FetchDataFromFireBase.shared.fetchUserPosts(forEmail: email ?? "") { alcohols in
            self.myPosts = alcohols
            self.allMyCellarInfo = alcohols
            self.searchedPosts = alcohols
            self.myPostsLoading = false
            self.tableView.reloadData()
            completion(true)
            if self.searchedPosts?.count == 0 {
                // self.noPostsLabel.isHidden = false
            } else {
                //self.noPostsLabel.isHidden = true
            }
        }
    }
    
    private func buttonSetup() {
        if let image = UIImage(named: StringConstants.ImageConstant.plus)?.withRenderingMode(.alwaysOriginal) {
            PlusButton.setImage(image, for: .normal)
        }
        PlusButton.contentMode = .scaleAspectFill
        PlusButton.borderColor = .green
        PlusButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        PlusButton.translatesAutoresizingMaskIntoConstraints = false
        PlusButton.tintColor = .blue
        view.addSubview(PlusButton)
        NSLayoutConstraint.activate([
            PlusButton.widthAnchor.constraint(equalToConstant: 60),
            PlusButton.heightAnchor.constraint(equalToConstant: 60),
            PlusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            PlusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        view.bringSubviewToFront(PlusButton)
    }
    
    @objc func myCellarDeleted(_ notification: NSNotification) {
        fetchData()
    }
    
    @objc func buttonTapped() {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

//MARK: TableViewDelegate
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return collectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        //        if indexPath.row == 1 {
        //            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTableViewCell", for: indexPath) as? BannerTableViewCell else {
        //                return UITableViewCell()
        //            }
        //
        //           // cell.bannerView = banner
        //           // view.addSubview(banner)
        //            return cell
        //        }
        //
        if (newsInfo.count == 0 && indexPath.section == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingViewCell", for: indexPath) as? LoadingViewCell else {
                return UITableViewCell()
            }
            cell.label.text = "No News available".localized()
            return cell
        } else if let posts = allPosts , posts.count == 0 && indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingViewCell", for: indexPath) as? LoadingViewCell else {
                return UITableViewCell()
            }
            cell.label.text = "No Cellar".localized()
            return cell
        } else if let posts = myPosts , posts.count == 0 && indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingViewCell", for: indexPath) as? LoadingViewCell else {
                return UITableViewCell()
            }
            cell.label.text = "No Cellar".localized()
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as? HomeViewCell else {
                return UITableViewCell()
            }
            cell.sectionIndex = indexPath.section
            cell.myPosts = self.myPosts
            cell.allPosts = self.allPosts
            cell.newsInfo = self.newsInfo
            cell.TotalallPosts = self.allCellarInfo
            cell.delegate = self
            cell.newsCollectionView.reloadData()
            return cell }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as! SectionHeaderView
        headerView.section = section
        headerView.delegate = self
        let attributedString = NSAttributedString(string: "See All".localized(), attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
            headerView.seeAllButton.isHidden = section == 0
        
        headerView.seeAllButton.setAttributedTitle(attributedString, for: .normal)
        headerView.configure(with: collectionArray[section].localized())

    return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    /// Added the footer view to avoid the cell overlapping when ad banner is visible
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isBannerVisible && section == 2 {
            return 50
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 50
        } else if indexPath.section == 0 {
            return 270
        }else {
            return 300
        }
    }
    
}
//MARK: SelectedIndexCollectionDelegate
extension HomeViewController : SelectedIndexCollectionDelegate {
    func selectedCollectionViewCellIndex(index: Int, section: Int) {
        handleCellAction(forSection: section, atIndex: index)
    }
    
    
    
    func tableViewCellDidTap(_ cell: UICollectionView, atIndex index: Int) {
        print(index)
        presentNewsDetailController(selectedNewsIndex: index)
    }
    
    func presentNewsDetailController(selectedNewsIndex: Int) {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController {
             // viewController.setNewsValues(details: self.newsInfo[selectedNewsIndex])
            viewController.newsDetails = self.newsInfo[selectedNewsIndex]
            present(viewController, animated: true)
        }
    }
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.homeLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
        case .large:
            self.homeLabel.font = UIFont.rubik(ofSize: 36 , weight: .medium)
        case .veryLarge:
            self.homeLabel.font = UIFont.rubik(ofSize: 38 , weight: .medium)
        case nil:
            break
        }
        tableView.reloadData()
    }
}


extension HomeViewController: GADFullScreenContentDelegate {
    
    // Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        setUpInterstitialAd { [weak self] in
            // This code block is executed once the ad is loaded
            // self?.presentInterstitialIfReady()
        }
        print("Ad did fail to present full screen content.")
    }
    
    // Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    // Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.isAdShown = false
        setUpInterstitialAd { [weak self] in
            print("ad is loaded")
        }
        print("Ad did dismiss full screen content.")
    }
    
}
 
extension HomeViewController: SectionHeaderViewDelegate {
    func sectionHeaderView(_ view: UITableViewHeaderFooterView, didTapOnSeeAll button: UIButton, withSection section: Int) {
        print("\(section)")
        if section == 1 {
            if let tabBarController = self.tabBarController as? HomeTabBarController {
                tabBarController.selectedIndex = 1
            }
        } else {
            if let tabBarController = self.tabBarController as? HomeTabBarController {
                tabBarController.selectedIndex = 2
            }
        }
        
    }
}
