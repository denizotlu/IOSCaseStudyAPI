//
//  Entities.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 6.10.2024.
//

import Foundation

struct ApiResult: Codable {
    let results: [ResultList]
}

struct ResultList: Codable {
    let screenshotUrls : [String]
    

}

