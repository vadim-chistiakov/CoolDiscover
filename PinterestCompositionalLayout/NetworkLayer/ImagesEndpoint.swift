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

extension ImagesEndpoint: Endpoint {
    var path: String {
        switch self {
        case .images(let page):
            return "/photos?page=\(page)"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .images:
            return .get
        }
    }
    
    var host: String {
        "api.unsplash.com"
    }
    
    var header: Header? {
        ["Authorization": "Client-ID \(accessKey)"]
    }
    
    var body: Body? {
        nil
    }
}
