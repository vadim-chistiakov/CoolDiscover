//
//  PinterestLayoutSection.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import Foundation
import UIKit

final class PinterestLayoutSection {
    
    var section: NSCollectionLayoutSection {
        .init(group: customLayoutGroup)
    }
    
    //MARK: - Private methods
    
    private let columnsCount: Int
    private let itemRatios: [Ratioable]
    private let spacing: CGFloat
    private let contentWidth: CGFloat
    
    private var padding: CGFloat {
        spacing / 2
    }
    
    // Padding around cells equal to the distance between cells
    private var insets: NSDirectionalEdgeInsets {
        return .init(top: padding, leading: padding, bottom: padding, trailing: padding)
    }
    
    private lazy var frames: [CGRect] = {
        calculateFrames()
    }()
    
    // Max height for section
    private lazy var sectionHeight: CGFloat = {
        (frames
            .map(\.maxY)
            .max() ?? 0
        ) + insets.bottom
    }()
    
    private lazy var customLayoutGroup: NSCollectionLayoutGroup = {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(sectionHeight)
        )
        return NSCollectionLayoutGroup.custom(layoutSize: layoutSize) { _ in
            self.frames.map { .init(frame: $0) }
        }
    }()
    
    init(
        columnsCount: Int,
        itemRatios: [Ratioable],
        spacing: CGFloat,
        contentWidth: CGFloat
    ) {
        self.columnsCount = columnsCount
        self.itemRatios = itemRatios
        self.spacing = spacing
        self.contentWidth = contentWidth
    }
    
    private func calculateFrames() -> [CGRect] {
        var contentHeight: CGFloat = 0
        
        // Subtract the margin from the total width and divide by the number of columns
        let columnWidth = (contentWidth - insets.leading - insets.trailing) / CGFloat(columnsCount)
        
        // Stores x-coordinate offset for each column. Not changing
        let xOffset = (0..<columnsCount).map { CGFloat($0) * columnWidth }
        
        var currentColumn = 0

        // Stores x-coordinate offset for each column.
        var yOffset: [CGFloat] = .init(repeating: 0, count: columnsCount)
        
        // Total number of frames
        var frames = [CGRect]()
        
        for index in 0..<itemRatios.count {
            let aspectRatio = itemRatios[index]
            
            // Сalculate the frame.
            let frame = CGRect(
                x: xOffset[currentColumn],
                y: yOffset[currentColumn],
                width: columnWidth,
                height: columnWidth / aspectRatio.ratio
            )
            // Total frame inset between cells and along edges
            .insetBy(dx: padding, dy: padding)
            // Additional top and left offset to account for padding
            .offsetBy(dx: insets.top, dy: insets.leading)
            // update the height to keep the correct aspect ratio
            .setHeight(ratio: aspectRatio.ratio)
            
            frames.append(frame)
        
            // Сalculate the height
            let columnLowestPoint = frame.maxY
            contentHeight = max(contentHeight, columnLowestPoint)
            yOffset[currentColumn] = columnLowestPoint
            // Adding the next element to the minimum height column.
            // We can move sequentially, but then there is a chance that some columns will be much longer than others
            currentColumn = yOffset.firstMinIndex ?? 0
        }
        return frames
    }
}

private extension Array where Element: Comparable {
    // Index of min element in Array
    var firstMinIndex: Int? {
        guard count > 0 else { return nil }
        var min = first
        var index = 0
        
        indices.forEach { i in
            let currentItem = self[i]
            if let minumum = min, currentItem < minumum {
                min = currentItem
                index = i
            }
        }
        
        return index
    }
}

private extension CGRect {
    func setHeight(ratio: CGFloat) -> CGRect {
        .init(x: minX, y: minY, width: width, height: width / ratio)
    }
}
