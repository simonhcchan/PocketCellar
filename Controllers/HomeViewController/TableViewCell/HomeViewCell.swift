//
//  HomeViewCell.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 06/04/24.
//

import UIKit



protocol SelectedIndexCollectionDelegate: AnyObject {
    func tableViewCellDidTap(_ cell: UICollectionView, atIndex index: Int)
    func selectedCollectionViewCellIndex(index:Int, section: Int)
}


class HomeViewCell: UITableViewCell {
    
    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    var sectionIndex : Int = 0
    var allPosts:[AlcoholDetailsModel]?
    var myPosts:[AlcoholDetailsModel]?
    var newsInfo:[NewsModel]?

    var TotalallPosts:[AlcoholDetailsModel]?
    var TotalmyPosts:[AlcoholDetailsModel]?
    weak var delegate: SelectedIndexCollectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newsCollectionView.allowsMultipleSelection = false
        newsCollectionView.isUserInteractionEnabled = true
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        
        let nib = UINib(nibName: StringConstants.Category.latestNewsCollectionViewCell, bundle: nil)
        newsCollectionView.register(nib, forCellWithReuseIdentifier: StringConstants.Category.latestNewsCollectionViewCell)
        
        let nibb = UINib(nibName: StringConstants.Category.cellarWorldCollectionViewCell, bundle: nil)
        newsCollectionView.register(nibb, forCellWithReuseIdentifier: StringConstants.Category.cellarWorldCollectionViewCell)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension HomeViewCell : UICollectionViewDelegate, UICollectionViewDataSource  {
    // MARK: Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sectionIndex {
        case 0 :  return newsInfo?.count ?? 0
        case 1 : return allPosts?.count ?? 0
        case 2 : return myPosts?.count ?? 0
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch sectionIndex {
            // Case: news
        case 0 :   guard let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.Category.latestNewsCollectionViewCell, for: indexPath) as? LatestNewsCollectionViewCell else {
            return UICollectionViewCell()
        }
            cell.postByLabel.text = "By admin".localized()
            cell.fontSetUp()
            cell.readMoreButton.setTitle("Read more..".localized(), for: .normal)
            if let posts = newsInfo {
                cell.setNewsValues(details: posts[indexPath.row])
            }
            
            cell.delegate = self
            cell.index = indexPath.item
            
            
            return cell
            // Case: All posts
        case 1 :  guard let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.Category.cellarWorldCollectionViewCell, for: indexPath) as? CellarWorldCollectionViewCell else {
            return UICollectionViewCell()
        }
            cell.tapButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            cell.tapButton.tag = indexPath.row
            cell.setUpLocaliction()
            cell.fontSetUp()
            if let posts = allPosts {
                cell.setValues(postDetails: posts[indexPath.row])
            }
            
            
            return cell
            // Case: My posts
        case 2 :  guard let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.Category.cellarWorldCollectionViewCell, for: indexPath) as? CellarWorldCollectionViewCell else {
            return UICollectionViewCell()
        }
            cell.tapButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            cell.tapButton.tag = indexPath.row
            cell.setUpLocaliction()
            cell.fontSetUp()
            if let posts = myPosts {
//                print("\(indexPath.row)")
//                print("\(posts)")
                cell.setValues(postDetails: posts[indexPath.row])
            }
            return cell
            
        default:  return UICollectionViewCell()
            
        }
        
    }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("\(indexPath.row)")
            print("\(sectionIndex)")
            var index = indexPath.row

            if sectionIndex == 1{
                let selectedItem = allPosts?[indexPath.row]
                if let selectedItem = allPosts?[indexPath.row],
                   let totalPosts = TotalallPosts,
                   let originalIndex = totalPosts.firstIndex(where: { $0.name == selectedItem.name }) {
                    index = originalIndex
                    print("Original index in TotalallPosts is \(originalIndex)")
                }
            }
            if sectionIndex == 2{
                let selectedItem = myPosts?[indexPath.row]
                if let selectedItem = myPosts?[indexPath.row],
                   let totalPosts = TotalmyPosts,
                   let originalIndex = totalPosts.firstIndex(where: { $0.name == selectedItem.name }) {
                    index = originalIndex
                    print("Original index in TotalallPosts is \(originalIndex)")
                }
            }
            delegate?.selectedCollectionViewCellIndex(index: index, section: sectionIndex)
            delegate?.tableViewCellDidTap(newsCollectionView, atIndex: indexPath.row)
        }

    @objc func buttonTapped(_ sender: UIButton) {
        print("\(sender.tag)")
        print("\(sectionIndex)")
        var index = sender.tag

        if sectionIndex == 1{
            let selectedItem = allPosts?[sender.tag]
            if let selectedItem = allPosts?[sender.tag],
               let totalPosts = TotalallPosts,
               let originalIndex = totalPosts.firstIndex(where: { $0.name == selectedItem.name }) {
                index = originalIndex
                print("Original index in TotalallPosts is \(originalIndex)")
            }
        }
        if sectionIndex == 2{
            let selectedItem = myPosts?[sender.tag]
            if let selectedItem = myPosts?[sender.tag],
               let totalPosts = TotalmyPosts,
               let originalIndex = totalPosts.firstIndex(where: { $0.name == selectedItem.name }) {
                index = originalIndex
                print("Original index in TotalallPosts is \(originalIndex)")
            }
        }
        delegate?.selectedCollectionViewCellIndex(index: index , section: sectionIndex)
    }
}

extension HomeViewCell : UICollectionViewDelegateFlowLayout {
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if sectionIndex == 0 {
            return CGSize(width: 211, height: 250)
        } else {
            return CGSize(width: 270, height: 300)
        }
    }
}

extension HomeViewCell : LatestNewsCollectionViewCellDelegate {
    
    func readMoreButtonDidTap(at index: Int) {
        // Handle the button tap action here with the index of the cell
        delegate?.tableViewCellDidTap(newsCollectionView, atIndex: index)
    }
}
