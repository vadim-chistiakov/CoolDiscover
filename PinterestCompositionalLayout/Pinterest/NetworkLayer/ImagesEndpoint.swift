//
//  ImagesEndpoint.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation
import EasyNetwork

enum ImagesEndpoint {
    case images(page: Int)
}

extension ImagesEndpoint: GetEndpoint {
    
    var header: Header? {
        ["Authorization": "Client-ID \(accessKey)"]
    }
    
    var host: String {
        "api.unsplash.com"
    }
    
    var path: String {
        switch self {
        case .images:
            return "/photos"
        }
    }
    
    var params: [URLQueryItem]? {
        switch self {
        case .images(let page):
            return [
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "30")
            ]
        }
    }

}
