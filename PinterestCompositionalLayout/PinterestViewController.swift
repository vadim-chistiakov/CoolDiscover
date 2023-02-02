//
//  ViewController.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import UIKit
import SnapKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, PictureModel>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, PictureModel>

enum Section {
    case main
}

final class PinterestViewController: UIViewController {
    
    private enum Const {
        static let cellId = "cellId"
    }
    
    private var pictures = [PictureModel]()
    private var dataSource: DataSource!
    private var snapshot: DataSourceSnapshot!
    
    
    private lazy var collectionView: UICollectionView = {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: Const.cellId)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        createData()
        configureDataSource()
    }
    
    private func configureUI() {
        title = "Pinterest Compositional Layout"
        view.backgroundColor = .lightGray
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension PinterestViewController: UICollectionViewDelegate  {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let picture = dataSource.itemIdentifier(for: indexPath) else { return }
        print(picture)
    }
}

extension PinterestViewController {
    private func createData() {
        for i in 0..<5 {
            pictures.append(PictureModel(title: "Picture \(i+1)", image: ""))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for i in 5..<10 {
                self.snapshot.insertItems(
                    [PictureModel(title: "Picture \(i+1)", image: "")],
                    afterItem: self.pictures[1]
                )
//                self.snapshot.appendItems([PictureModel(title: "Picture \(i+1)", image: "")])
                self.dataSource.apply(self.snapshot, animatingDifferences: true)
            }
        }
    }
                            
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension:  .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(0.5) //height??
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureDataSource() {
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(pictures)
        
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, contact) -> PictureCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.cellId, for: indexPath) as! PictureCell
                cell.titleLabel.text = contact.title
                return cell
            })
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
