//
//  PinterestLayout.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import Foundation
import UIKit

class PinterestLayout {

    func makeVariousAspectRatioLayoutSection(
        columnsCount: Int,
        itemRatios: [Ratioable],
        spacing: CGFloat = 0,
        contentWidth: CGFloat
    ) -> NSCollectionLayoutSection {
        guard columnsCount >= 2 else {
            assertionFailure("Минимальное кол-во столбцов - 2")
            return .singleItem
        }
        
        // отступы вокруг ячеек равные расстоянию между ячейками
        let insets = NSDirectionalEdgeInsets(uniform: spacing / 2)
        
        // ручной расчет фреймов ячеек
        let frames = calculateFrames(
            width: contentWidth,
            itemRatios: itemRatios.map { $0.ratio },
            columnsCount: columnsCount,
            spacing: spacing,
            insets: insets
        )
        
        // общая высота контента в секции
        let height = (frames.suffix(columnsCount).map(\.maxY).max() ?? 0.0) + insets.bottom
        
        let customGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        
        let customGroup = NSCollectionLayoutGroup.custom(layoutSize: customGroupSize) { _ in
            frames.map {
                NSCollectionLayoutGroupCustomItem(frame: $0)
            }
        }
        
        return NSCollectionLayoutSection(group: customGroup)
    }
    
    private func calculateFrames(
        width: CGFloat,
        itemRatios: [CGFloat],
        columnsCount: Int,
        spacing: CGFloat,
        insets: NSDirectionalEdgeInsets
    ) -> [CGRect] {
        var contentHeight: CGFloat = 0
        
        // вычитаем из общей ширины боковой отступ
        let columnWidth = (width - insets.leading - insets.trailing) / CGFloat(columnsCount)
        var xOffset: [CGFloat] = []
        for column in 0..<columnsCount {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: columnsCount)
        
        var frames = [CGRect]()
        
        for index in 0..<itemRatios.count {
            let aspectRatio = itemRatios[index]
            
            // Предварительный расчет фрейма для ячейки без учета отступов
            // Поскольку после добавления к фрейму единого отступа изменится ratio,
            // ниже высота изменяется, отдельно
            let tempFrame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: columnWidth / aspectRatio
            )
            
            let insetFrame = tempFrame
                // общее смещение фрейма (между ячейками и по краям)
                .insetBy(dx: spacing / 2, dy: spacing / 2)
                // дополнительное смещение сверху и слева для учета отступа
                .offsetBy(dx: insets.top, dy: insets.leading)
                // обновляем высоту чтобы сохранить правильные пропорции
                .setHeight(ratio: aspectRatio)
            
            frames.append(insetFrame)
        
            // расчет вертикальных размеров
            let columnLowestPoint = insetFrame.maxY
            contentHeight = max(contentHeight, columnLowestPoint)
            yOffset[column] = columnLowestPoint
            
            // добавлением следующий элемент в колонку с минимальной высотой
            column = yOffset.firstMinIndex ?? 0
        }
        return frames
    }
}

// MARK: - Helpers

private extension NSDirectionalEdgeInsets {
    init(uniform: CGFloat) {
        self.init(top: uniform, leading: uniform, bottom: uniform, trailing: uniform)
    }
}

private extension NSCollectionLayoutSection {
    static var singleItem: NSCollectionLayoutSection {
        .init(
            group: NSCollectionLayoutGroup(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
        )
    }
}

private extension Array where Element: Comparable {
    var firstMinIndex: Int? {
        guard count > 0 else { return nil }
        var min = first
        var index: Int = 0
        
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
        CGRect(x: minX, y: minY, width: width, height: width / ratio)
    }
}
