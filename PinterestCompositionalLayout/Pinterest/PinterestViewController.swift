//
//  ViewController.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 01.02.2023.
//

import UIKit
import SnapKit
import Combine

typealias DataSource = UICollectionViewDiffableDataSource<Section, PictureModel>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, PictureModel>

enum Section {
    case main
}

final class PinterestViewController: UIViewController, UICollectionViewDelegate {
    
    private enum Const {
        static let cellId = "cellId"
    }
    
    private let viewModel: PinterestViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: PinterestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: Const.cellId)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefresh()
        configureDataSource()
        viewModel
            .loadImages(animatingDifferences: false)
            .sink { [weak self] ratios in
                self?.configureLayout(ratios: ratios)
            }
            .store(in: &cancellables)
    }
    
    private func configureUI() {
        title = "Pinterest Compositional Layout"
        view.backgroundColor = .lightGray
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .gray
        collectionView.refreshControl = refreshControl
    }
    
    @objc
    private func handleRefresh() {
        guard !viewModel.isRefreshing else { return }
        viewModel
            .refresh()
            .sink { [weak self] ratios in
                self?.configureLayout(ratios: ratios)
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: &cancellables)
    }
    
    private func configureLayout(ratios: [CGFloat]) {
        collectionView.setCollectionViewLayout(
            createLayout(ratios: ratios),
            animated: false
        )
    }

}

extension PinterestViewController {

    private func createUsialLayout() -> UICollectionViewLayout  {
        let itemSize = NSCollectionLayoutSize(
            widthDimension:  .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
                            
    private func createLayout(ratios: [CGFloat]) -> UICollectionViewLayout {
        let pinterestLayout = PinterestLayout()
        let section = pinterestLayout.makeVariousAspectRatioLayoutSection(
            columnsCount: 2,
            itemRatios: ratios,
            spacing: 10,
            contentWidth: view.bounds.width
        )
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureDataSource() {
        viewModel.dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, model) -> PictureCell? in
                guard let self else { return .init() }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.cellId, for: indexPath) as! PictureCell
                cell.imageView.image = UIImage(blurHash: model.blurHash, size: model.blurHashSize)
                
                //TODO: - Как лучше организовать запрос картинок?
                self.viewModel.loadImage(for: indexPath.item)
                    .sink { _ in }
                    receiveValue: { data in
                        cell.imageView.image = UIImage(data: data)
                    }
                    .store(in: &self.cancellables)

                return cell
            })
    }
}
