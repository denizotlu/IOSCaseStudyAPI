//
//  Interactor.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 6.10.2024.
//

import Foundation
import UIKit

protocol InteractorProtocol{
    
    var presenter : PresenterProtocol? {get set}
    func fetchApi()
    
}

class ScreenInteractor : InteractorProtocol {
    var presenter: PresenterProtocol?
    
    
    func fetchApi() {
        let urlString = "https://itunes.apple.com/search?term=software&media=software"
        
        guard let url = URL(string: urlString) else {return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("API çağrısında hata: \(error.localizedDescription)")
                
                self.presenter?.didGetApi(completion: .failure(ErrorScenarios.networkError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 299 else {
                print("response 400")
                self.presenter?.didGetApi(completion: .failure(ErrorScenarios.networkError))
                return
            }
            
            guard let data = data else {
                print("Gelen data boş")
                self.presenter?.didGetApi(completion: .failure(ErrorScenarios.networkError))
                return
                
            }
            
            do{
                
                let apiResponse = try JSONDecoder().decode(ApiResult.self, from: data)
                let allScreenshotUrls = apiResponse.results.flatMap { $0.screenshotUrls }
                self.presenter?.didGetApi(completion: .success(allScreenshotUrls))
                
            }catch{
                print("Parsing: \(error.localizedDescription)")
                self.presenter?.didGetApi(completion: .failure(ErrorScenarios.parsingError))
            }
            
            
            
            
        }
        
        task.resume()
    }
    
    
    
    
}
   
