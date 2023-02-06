//
//  PinterestLayoutExample.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import Foundation

import UIKit

//class PinterestLayoutExample: UICollectionViewCompositionalLayout {
//
//    init() {
//        super.init()
//        configureLayout()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configureLayout() {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .absolute(250))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
//                                                     subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//
//        self.collectionViewContentSize = CGSize(width: collectionView?.frame.width ?? 0, height: 1000)
//        self.section = section
//    }
//}
