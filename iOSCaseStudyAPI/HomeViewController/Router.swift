//
//  Router.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 6.10.2024.
//

import Foundation
import UIKit



typealias EntryPoint = ViewProtocol & UIViewController

protocol RouterProtocol {
    var entry : EntryPoint? {get}
    static func startExecution() -> RouterProtocol
}

class CryptoRouter : RouterProtocol {
    var entry: EntryPoint?
    
    static func startExecution() -> RouterProtocol {
        
        let router = CryptoRouter()
        
        var view : ViewProtocol = ScreenView()
        var presenter : PresenterProtocol = ScreenPresenter()
        var interactor : InteractorProtocol = ScreenInteractor()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        
        interactor.presenter = presenter
        
        router.entry = view as? EntryPoint
        
        return router
        
    }
    
}
