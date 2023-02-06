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

enum Section: Int, CaseIterable {
    case carousel
    case widget
    case pinterest
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
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray
        collectionView.showsHorizontalScrollIndicator = false
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
    
    private func configureLayout(ratios: [Ratioable]) {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, enviroment in
            guard let self,
                    let section = Section(rawValue: sectionIndex)
            else { return nil }
            switch section {
            case .carousel :
                return self.carouselBannerSection()
            case .widget :
                return self.widgetBannerSection()
            case .pinterest:
                return self.pinterestSection(ratios: ratios)
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

}

extension PinterestViewController {
    
    private func carouselBannerSection() -> NSCollectionLayoutSection {
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
    
    private func widgetBannerSection() -> NSCollectionLayoutSection {
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
                            
    private func pinterestSection(ratios: [Ratioable]) -> NSCollectionLayoutSection {
        PinterestLayout().makeVariousAspectRatioLayoutSection(
            columnsCount: 2,
            itemRatios: ratios,
            spacing: 10,
            contentWidth: view.bounds.width
        )
    }
    
    private func configureDataSource() {
        viewModel.dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, model) -> PictureCell? in
                guard let self,
                      let section = Section(rawValue: indexPath.section)
                else { return .init() }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.cellId, for: indexPath) as! PictureCell
                cell.imageView.image = UIImage(blurHash: model.blurHash, size: model.blurHashSize)
                
                //TODO: - Как лучше организовать запрос картинок?
                
                self.viewModel.loadImage(for: indexPath.item, inSection: section)
                    .sink { _ in }
                    receiveValue: { data in
                        cell.imageView.image = UIImage(data: data)
                    }
                    .store(in: &self.cancellables)

                return cell
            }
        )
    }
}
