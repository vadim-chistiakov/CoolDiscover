//
//  CustomCompositionalLayout.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import Foundation
import UIKit

final class CustomCompositionalLayout {
    
    static func layout(ratios: [Ratioable], contentWidth: CGFloat) -> UICollectionViewCompositionalLayout {
        .init { sectionIndex, enviroment in
            guard let section = Section(rawValue: sectionIndex)
            else { return nil }
            switch section {
            case .carousel :
                return carouselBannerSection()
            case .widget :
                return widgetBannerSection()
            case .pinterest:
                return pinterestSection(ratios: ratios, contentWidth: contentWidth)
            }
        }
    }
    
    private static func carouselBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.8
                let maxScale: CGFloat = 1.0
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return section
    }
    
    private static func widgetBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.2),
            heightDimension: .fractionalWidth(0.3)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 5, bottom: 10, trailing: 5)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    private static func pinterestSection(
        ratios: [Ratioable],
        contentWidth: CGFloat
    ) -> NSCollectionLayoutSection {
        PinterestLayoutSection(
            columnsCount: 2,
            itemRatios: ratios,
            spacing: 10,
            contentWidth: contentWidth
        ).section
    }
    
}
