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
        view.backgroundColor = .black
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
        let layout = CustomCompositionalLayout.layout(
            ratios: ratios,
            contentWidth: view.frame.width
        )
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

}

extension PinterestViewController {
    
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
                cell.titleLabel.text = "\(indexPath.item)"
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
