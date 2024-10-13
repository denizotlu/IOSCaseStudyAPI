//
//  PreviewController.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 13.10.2024.
//

import Foundation
import UIKit


class PreviewController: UIViewController {
    
    var imageView = UIImageView()
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupImageView()
        loadImage()
        navBarButton()
        
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadImage() {
        guard let imageUrl = imageUrl, let url = URL(string: imageUrl) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func navBarButton() {
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem()
        let closeButton = UIBarButtonItem(title: "Kapat", style: UIBarButtonItem.Style.done, target: self, action: #selector(back))
        navItem.rightBarButtonItem = closeButton
        
        navBar.setItems([navItem], animated: false)
        
        /*   let closeButton = UIButton(type: .system)
         closeButton.setTitle("Kapat", for: .normal)
         closeButton.translatesAutoresizingMaskIntoConstraints = false
         closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
         view.addSubview(closeButton)*/
 
      /*  NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])*/
         
      
     }
     
     @objc private func back() {
         dismiss(animated: true, completion: nil)
     }
    
    
}
