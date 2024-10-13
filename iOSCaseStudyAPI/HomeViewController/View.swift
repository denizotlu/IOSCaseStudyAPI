//
//  View.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 6.10.2024.
//

import Foundation
import UIKit



protocol ViewProtocol {
    
    var presenter: PresenterProtocol? { get set }
    func showApi(_ screenUrl: [String])
    func failApi(with noData: String)
    
}


class ScreenView: UIViewController, ViewProtocol, UISearchBarDelegate {
    
    
    enum SectionType: Int {
        case zeroToHundred = 0
        case hundredToTwofifty = 1
        case twofiftyTofivehundred = 2
        case fivehundredPlus = 3
        
        var title: String {
            switch self {
            case .zeroToHundred:
                return "0-100kb"
            case .hundredToTwofifty:
                return "100-250kb"
            case .twofiftyTofivehundred:
                return "250-500kb"
            case .fivehundredPlus:
                return "500+kb"
            }
        }
    }
    
    var presenter: PresenterProtocol?
    
    var screenShots: [String] = []

    private let searchBar = UISearchBar()
    
    
    
    
    private let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = false
        layout.scrollDirection = .vertical
        let cvframe = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cvframe.translatesAutoresizingMaskIntoConstraints = false
        
        return cvframe
    }()
    
    private var noDataLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
  


    
  
    
    private let operationQueue = OperationQueue()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        operationQueue.maxConcurrentOperationCount = 3
        
        setupSearchBar()
        setupUI()
        
    }
    
    
    
   
    func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    
    func showApi(_ screenUrl: [String]) {
        DispatchQueue.main.async {
            self.screenShots = screenUrl
            print("Veri geldi VİEW'e: \(screenUrl)")

            for url in screenUrl {
                self.downloadImage(from: url)
            }

            self.collectionView.reloadData()
        }
    }

    /*  func categorizeURLs() {
     firstSection.removeAll()
     secondSection.removeAll()
     thirdSection.removeAll()
     fourthSection.removeAll()
     
     for url in screenShots {
     downloadImage(from: url)
     }
     }*/
    
    
    func failApi(with noData: String) {
        DispatchQueue.main.async {
            self.screenShots = []
            self.noDataLabel.text = noData
            self.collectionView.isHidden = true
            self.noDataLabel.isHidden = false
            
            if !noData.isEmpty {
                self.searchBar.isHidden = true
            }
        }
    }
    
    
    
  
    
    
    
    func categorizeImage(urlString: String, sizeKB: Double) {
        var sectionIndex: Int = 0

        switch sizeKB {
        case 0..<100:
            firstSection.append(urlString)
            sectionIndex = SectionType.zeroToHundred.rawValue
        case 100..<250:
            secondSection.append(urlString)
            sectionIndex = SectionType.hundredToTwofifty.rawValue
        case 250..<500:
            thirdSection.append(urlString)
            sectionIndex = SectionType.twofiftyTofivehundred.rawValue
        default:
            fourthSection.append(urlString)
            sectionIndex = SectionType.fivehundredPlus.rawValue
        }

        let currentItemCount = collectionView.numberOfItems(inSection: sectionIndex)
        let indexPath = IndexPath(item: currentItemCount, section: sectionIndex)
        
         if currentItemCount < (sectionIndex == 0 ? firstSection.count : sectionIndex == 1 ? secondSection.count : sectionIndex == 2 ? thirdSection.count : fourthSection.count) {
             collectionView.insertItems(at: [indexPath])
        }
    }

    
    
    
    var firstSection = [String]()
    var secondSection = [String]()
    var thirdSection = [String]()
    var fourthSection = [String]()
    
    var isSearching = false
    


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            collectionView.reloadData()
            
         presenter?.interactor?.fetchApi()
        } else {
            
            isSearching = true
            
            firstSection = firstSection.filter { $0.contains(searchText) }
            secondSection = secondSection.filter { $0.contains(searchText) }
            thirdSection = thirdSection.filter { $0.contains(searchText) }
            fourthSection = fourthSection.filter { $0.contains(searchText) }
        }
        
        collectionView.reloadData()
    }

    
    
    
    
    
    

    func downloadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        let downloadOperation = BlockOperation {
            if let imageData = try? Data(contentsOf: url)  /*, let image = UIImage(data: imageData) */ {
                let imageSizeKB = Double(imageData.count) / 1024
                
                DispatchQueue.main.async {
                    self.categorizeImage(urlString: urlString, sizeKB: imageSizeKB)
                }
            }
        }
       operationQueue.addOperation(downloadOperation)
    }
    
    
    
}




  


extension ScreenView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case SectionType.zeroToHundred.rawValue:
            return firstSection.count
        case SectionType.hundredToTwofifty.rawValue:
            return secondSection.count
        case SectionType.twofiftyTofivehundred.rawValue:
            return thirdSection.count
        case SectionType.fivehundredPlus.rawValue:
            return fourthSection.count
        default:
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        
        let sectionType = SectionType(rawValue: indexPath.section)
        switch sectionType {
        case .zeroToHundred:
            cell.configureCell(with: self.firstSection[indexPath.row])
        case .hundredToTwofifty:
            cell.configureCell(with: self.secondSection[indexPath.row])
        case .twofiftyTofivehundred:
            cell.configureCell(with: self.thirdSection[indexPath.row])
        case .fivehundredPlus:
            cell.configureCell(with: self.fourthSection[indexPath.row])
        case .none:
            break
        }
        return cell
    }
    

    
    
    
    // Section başlık https://stackoverflow.com/questions/30005348/how-do-i-add-a-section-title-in-uicollectionview
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
            
            if let sectionType = SectionType(rawValue: indexPath.section) {
                headerView.titleLabel.text = sectionType.title
            }
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }

    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 180)
    }
    
    
    
    
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUrl : String
           
           switch indexPath.section {
           case SectionType.zeroToHundred.rawValue:
               selectedUrl = firstSection[indexPath.row]
           case SectionType.hundredToTwofifty.rawValue:
               selectedUrl = secondSection[indexPath.row]
           case SectionType.twofiftyTofivehundred.rawValue:
               selectedUrl = thirdSection[indexPath.row]
           case SectionType.fivehundredPlus.rawValue:
               selectedUrl = fourthSection[indexPath.row]
           default:
               return
           }
           
        let previewVC = PreviewController()
        previewVC.imageUrl = selectedUrl
        present(previewVC, animated: true, completion: nil)
        
       }
   
    
    
    
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(noDataLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
    }
    
    
    
    
}














