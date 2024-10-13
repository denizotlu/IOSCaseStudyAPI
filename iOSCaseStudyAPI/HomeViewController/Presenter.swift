//
//  Presenter.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 6.10.2024.
//

import Foundation
import UIKit

enum ErrorScenarios: String, Error {
    case networkError
    case parsingError
    case noDataError
}




protocol PresenterProtocol {
    var view: ViewProtocol? { get set }
    var interactor: InteractorProtocol? { get set }
    var router: RouterProtocol? { get set }
    
    func didGetApi(completion: Result<[String], Error>)

}

class ScreenPresenter: PresenterProtocol {
    var firstSection = [String]()
    var secondSection = [String]()
    var thirdSection = [String]()
    var fourthSection = [String]()
    

    
    var view: ViewProtocol?
    var router: RouterProtocol?
    
    var interactor: InteractorProtocol? {
        
        didSet {
            interactor?.fetchApi()
        }
    }
    
    func didGetApi(completion: Result<[String], Error>) {
        switch completion {
        case .success(let screenShot):
          //  print("Veri geldi presenter: \(screenShot)")
            view?.showApi(screenShot)
            
        case .failure(let noData):
            print("PResenter fail: \(noData)")
            view?.failApi(with: "NO DATA")
        }
    }
    
    
    
    
    
    
}
