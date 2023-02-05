//
//  PinterestViewModel.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation
import Combine
import EasyNetwork

final class PinterestViewModel {
    
    private var pictures = [PictureModel]() {
        didSet {
            configureDataSource()
        }
    }
    
    var dataSource: DataSource!
    var snapshot = DataSourceSnapshot()

    private let imagesNetworkService: ImagesNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(imagesNetworkService: ImagesNetworkService) {
        self.imagesNetworkService = imagesNetworkService
    }
    
    func loadImages() -> AnyPublisher<[CGFloat], Never> {
        imagesNetworkService.getImages(page: 1)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] models in
                self?.pictures = models
            })
            .map { $0.map { $0.ratio } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func loadImage(for index: Int) -> AnyPublisher<Data, RequestError> {
        imagesNetworkService.getImage(urlString: pictures[index].urls.full)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func configureDataSource() {
        snapshot.appendSections([Section.main])
        snapshot.appendItems(pictures)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
