//
//  PictureModel.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import Foundation

struct PictureModel: Hashable, Decodable {
    
    // MARK: - Urls
    struct Urls: Hashable, Decodable {
        let raw, full, regular, small, thumb: String
    }
    
    let description: String
    let urls: Urls
    let width: CGFloat
    let height: CGFloat
}

extension PictureModel: Ratioable {
    var ratio: CGFloat {
        width / height
    }
}
