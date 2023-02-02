//
//  PictureCell.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 02.02.2023.
//

import UIKit

final class PictureCell: UICollectionViewCell {
    
    lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
