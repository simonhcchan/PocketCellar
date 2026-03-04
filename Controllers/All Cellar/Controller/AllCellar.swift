//
//  ViewController.swift
//  YourWineLabel
//
//  Created by IE14 on 11/03/24.
//

import UIKit
import GoogleMobileAds
class AllCellar: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noPostsLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var allCellarLabel: UILabel!
    @IBOutlet private var filterButton: UIButton!
    
    private var allPosts:[AlcoholDetailsModel]?
    private var searchedPosts:[AlcoholDetailsModel]?
    private var filteredPosts:[AlcoholDetailsModel]?
    let PlusButton = UIButton(type: .custom)
    var indexForFilter = 3
    var filterDetails:FilterParameters?
    var isAdShown: Bool = false
    var isBannerVisible = true
    var scrollToIndex: Int = 1
    private var interstitial: GADInterstitialAd?
    var names:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUpLocalization()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.setNavigationBarHidden(true, animated: true)
        let nib = UINib(nibName: MyPostsTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MyPostsTableViewCell.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(myCellarDeleted(_:)), name: NSNotification.Name(rawValue: "MyCellarDeleted"), object: nil)
        buttonSetup()
        if isBannerVisible {
            if UserDefaults.standard.bool(forKey: "isUserSubscribed") == false {
                setUpBannerView()
            }

        }
        fetchDataFromFirebase()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)  // Dismisses the keyboard for all text fields in the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.text = ""
        self.hidesBottomBarWhenPushed = false
        setUpLocalization()
        setupFont()
        filteredPosts = nil
        if filterDetails == nil {
            filterButton.tintColor = .white
        } else {
            filterButton.tintColor = .blue
        }
        print("On appear ad called")
        
        if let scrollTo = UserDefaults.standard.integer(forKey: "allCellarSelectedIndex") as? Int {
            self.scrollToIndex = scrollTo
            showIndexInTableView(index: scrollToIndex)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchedPosts = self.allPosts
        filterDetails = nil
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
    }
    
    @objc func buttonTapped() {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func myCellarDeleted(_ notification: NSNotification) {
        fetchDataFromFirebase()
    }
    
    func showIndexInTableView(index: Int) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            UserDefaults.standard.setValue(0, forKey: "allCellarSelectedIndex")
        }
    }
    
    private func fetchDataFromFirebase() {
        FetchDataFromFireBase.shared.fetchAllPosts { posts in
            self.allPosts = posts
            self.searchedPosts = posts
            self.activityIndicator.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.showIndexInTableView(index: self.scrollToIndex)
            }
            if self.searchedPosts?.count == 0 {
                self.noPostsLabel.isHidden = false
            } else {
                self.noPostsLabel.isHidden = true
            }
            
        }
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
    
    @IBAction func filterButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        searchTextField.text = ""
        if let allPosts = self.filteredPosts {
            searchedPosts = allPosts
        } else {
            guard let allPosts = self.allPosts else {
                return
            }
            searchedPosts = allPosts
        }
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        tableView.reloadData()
        viewController.delegate = self
        viewController.filterDetails = filterDetails
        viewController.hidesBottomBarWhenPushed = true
        present(viewController, animated: true)
    }
    
    @IBAction func searchTextField(_ sender: Any) {
        if let char = searchTextField.text {
            let trimmedPrefix = char.trimmingCharacters(in: .whitespacesAndNewlines)
            if char.count == 0 || trimmedPrefix.count == 0 {
                if let allPosts = self.filteredPosts {
                    searchedPosts = allPosts
                } else {
                    guard let allPosts = self.allPosts else {
                        return
                    }
                    searchedPosts = allPosts
                }
                tableView.reloadData()
                return
            }
            
            if let allPosts = self.filteredPosts {
                let filterAlcoholDetails = filterAlcoholDetails(alcoholDetails: allPosts, containing: trimmedPrefix)
                searchedPosts = filterAlcoholDetails
                
            } else {
                guard let allPosts = self.allPosts else {
                    return
                }
                let filterAlcoholDetails = filterAlcoholDetails(alcoholDetails: allPosts, containing: trimmedPrefix)
                searchedPosts = filterAlcoholDetails
                
            }
            if self.searchedPosts?.count == 0 {
                self.noPostsLabel.isHidden = false
            } else {
                self.noPostsLabel.isHidden = true
            }
            
            tableView.reloadData()
        }
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        searchTextField.text = ""
        if let allPosts = self.filteredPosts {
            searchedPosts = allPosts
        } else {
            guard let allPosts = self.allPosts else {
                return
            }
            searchedPosts = allPosts
        }
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        tableView.reloadData()
    }
}

extension AllCellar {
    private func filterAlcoholDetails(alcoholDetails: [AlcoholDetailsModel], containing prefix: String) -> [AlcoholDetailsModel] {
        let filteredDetails = alcoholDetails.filter { detail in
            let lowercasePrefix = prefix.lowercased()
            let nameMatches = detail.name?.lowercased().contains(lowercasePrefix) ?? false
            let makerMatches = detail.maker?.lowercased().contains(lowercasePrefix) ?? false
            let originMatches = detail.origin?.lowercased().contains(lowercasePrefix) ?? false
            let shopFromMatches = detail.shopFrom?.lowercased().contains(lowercasePrefix) ?? false
            let reviewMatches = detail.yourReview?.lowercased().contains(lowercasePrefix) ?? false
            // Return true if any of the properties match
            return nameMatches || makerMatches || originMatches || shopFromMatches || reviewMatches
        }
        return filteredDetails
    }
    
    private func buttonSetup(){
        if let image = UIImage(named: StringConstants.ImageConstant.plus)?.withRenderingMode(.alwaysOriginal) {
            PlusButton.setImage(image, for: .normal)
        }
        PlusButton.contentMode = .scaleAspectFit
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
    
}

extension AllCellar: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyPostsTableViewCell.identifier,for: indexPath) as! MyPostsTableViewCell
        cell.setupFont()
        cell.setUpLocalization()
        cell.delegate = self
        cell.editButton.isHidden = true
        cell.shareButton.isHidden = true
        cell.yourRemarkStack.isHidden = true
        let shareImage = UIImage(named:StringConstants.ImageConstant.share)
        cell.deleteButton.setImage(shareImage, for: .normal)
        if let posts = searchedPosts {
            cell.setValues(postDetails: posts[indexPath.row], at: indexPath)
        }

                    self.hideLoader()
               

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isBannerVisible {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func didTapOnImage(image: String) {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let imageViewController = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
            imageViewController.selectedImage = image.toImage()
            present(imageViewController, animated: true)
        }
    }
}

extension AllCellar: FilterViewControllerDelegate {
    func applyFilter(alcoholDetails: [AlcoholDetailsModel], filter: FilterParameters?) {
       // self.showLoader()
        searchedPosts = alcoholDetails
        filteredPosts = alcoholDetails
        filterDetails = filter
        self.tableView.reloadData()
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        
        if filterDetails == nil {
            filterButton.tintColor = .white
        } else {

            filterButton.tintColor = .blue
        }

    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension AllCellar {
    func filterPostsBySearchTexts(_ searchStrings: [String]) -> [AlcoholDetailsModel] {
        
        if let allPosts = self.filteredPosts {
            let filteredPosts = allPosts.filter { post in
                if let name = post.name {
                    return searchStrings.contains { searchString in
                        return name.localizedCaseInsensitiveContains(searchString)
                    }
                }
                return false
            }
            return filteredPosts
        } else {
            guard let allPosts = self.allPosts else {
                return []
            }
            let filteredPosts = allPosts.filter { post in
                if let name = post.name {
                    // Check if the name contains any of the search strings
                    return searchStrings.contains { searchString in
                        return name.localizedCaseInsensitiveContains(searchString)
                    }
                }
                return false
            }
            return filteredPosts
        }
    }
    
    private func setUpLocalization(){
        self.allCellarLabel.text = "Cellar World".localized()
        self.searchTextField.placeholder = "Search".localized()
        self.noPostsLabel.text = "No Cellar".localized()
    }
}

extension AllCellar {
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.allCellarLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
        case .large:
            self.allCellarLabel.font = UIFont.rubik(ofSize: 36 , weight: .medium)
        case .veryLarge:
            self.allCellarLabel.font = UIFont.rubik(ofSize: 38 , weight: .medium)
        case nil:
            break
        }
        tableView.reloadData()
    }
    
    func takeScreenshotOfCell(at indexPath: IndexPath) -> UIImage? {
        guard let cell = tableView.cellForRow(at: indexPath) else {
          return nil
        }
    
        let renderer = UIGraphicsImageRenderer(size: cell.bounds.size)
        
        let image = renderer.image { context in
          cell.layer.render(in: context.cgContext)
        }
        return image
      }
}
extension AllCellar:MyPostsTableViewCellDelegate {
    func showToast(message: String) {
        ToastManager.showToast(message: message, onView: self.view)
    }
    
    func shareButtonTapped(at indexPath: IndexPath, documentID: String, sender: UIButton) {
        //
    }
    
    func editButtonTapped(postDetails: AlcoholDetailsModel) {
        //
    }
    
    func deleteOrShareButtonTapped(at indexPath: IndexPath, documentID: String, sender: UIButton) {
        guard let post = allPosts?[indexPath.row] else {
          return
        }
        // Create text for sharing
        var sharingText = """
        I wanna share you this \(post.category!), sure you will find this great too!
        Category: \(post.category!)
        Sub category: \(post.type!)
        Name: \(post.name!)
        Maker: \(post.maker!)
        Origin: \(post.origin!)
        Shop from: \(post.shopFrom!)
        Price: \(post.currency!)\(post.price!)
        Purchase Date: \(post.purchaseDate!)
        Rating: \(String(repeating: "⭐️", count: post.yourRating!))
        Do you recommend?: \(post.doYouRecommended!)
        Review: \(post.yourReview!)
        """
       
        sharingText += "\n\nCheck out Pocket Cellar for more cellar reviews and recommendations: https://apps.apple.com/us/app/pocket-cellar/id6497877589"
        guard let imageData = post.image?.toImage() else {
            print("Failed to convert image to data")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [sharingText,imageData], applicationActivities: nil)
        activityViewController.setValue("Pocket Cellar", forKey: "subject")
        activityViewController.excludedActivityTypes = [
          .addToReadingList,
          .assignToContact
        ]
        
        if let popoverController = activityViewController.popoverPresentationController {
          popoverController.sourceView = sender
          popoverController.sourceRect = sender.bounds
        }
        present(activityViewController, animated: true, completion: nil)
      }
}

