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
        layout.sectionHeadersPinToVisibleBounds = true // Ensure headers stay visible
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
    
    var firstSection = [String]()
    var secondSection = [String]()
    var thirdSection = [String]()
    var fourthSection = [String]()
    
    // Image download queue
    private let imageDownloadQueue = OperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imageDownloadQueue.maxConcurrentOperationCount = 3 // Max 3 downloads at a time
        
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
            self.categorizeURLs()
            print("Veri geldi VİEW'e: \(screenUrl)")
        }
    }

    func categorizeURLs() {
        firstSection.removeAll()
        secondSection.removeAll()
        thirdSection.removeAll()
        fourthSection.removeAll()

        for url in screenShots {
            downloadImage(from: url)
        }
    }

    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let downloadOperation = BlockOperation {
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                let imageSizeKB = Double(imageData.count) / 1024.0
                
                DispatchQueue.main.async {
                    self.categorizeImage(urlString: urlString, sizeKB: imageSizeKB)
                }
            }
        }
        imageDownloadQueue.addOperation(downloadOperation)
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
        
        // Reload only the newly downloaded image cell
        let indexPath = IndexPath(item: collectionView.numberOfItems(inSection: sectionIndex), section: sectionIndex)
        collectionView.insertItems(at: [indexPath])
    }

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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            isSearching = false
            // Orijinal dizileri geri yükle
            firstSection = filteredFirstSection
            secondSection = filteredSecondSection
            thirdSection = filteredThirdSection
            fourthSection = filteredFourthSection
        } else {
            isSearching = true
            
            // Filtreleme yap
            filteredFirstSection = firstSection.filter { $0.contains(searchText) }
            filteredSecondSection = secondSection.filter { $0.contains(searchText) }
            filteredThirdSection = thirdSection.filter { $0.contains(searchText) }
            filteredFourthSection = fourthSection.filter { $0.contains(searchText) }
            
            // Filtrelenmiş dizileri güncelle
            firstSection = filteredFirstSection
            secondSection = filteredSecondSection
            thirdSection = filteredThirdSection
            fourthSection = filteredFourthSection
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
        let urlString: String
        
        switch indexPath.section {
        case SectionType.zeroToHundred.rawValue:
            urlString = firstSection[indexPath.row]
        case SectionType.hundredToTwofifty.rawValue:
            urlString = secondSection[indexPath.row]
        case SectionType.twofiftyTofivehundred.rawValue:
            urlString = thirdSection[indexPath.row]
        case SectionType.fivehundredPlus.rawValue:
            urlString = fourthSection[indexPath.row]
        default:
            return UICollectionViewCell()
        }
        
        cell.configureCell(with: urlString)
        return cell
    }

    // Section başlıklarını göstermek için
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableView.identifier, for: indexPath) as! CollectionReusableView
            
            if let sectionType = SectionType(rawValue: indexPath.section) {
                headerView.titleLabel.text = sectionType.title
            }
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
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














