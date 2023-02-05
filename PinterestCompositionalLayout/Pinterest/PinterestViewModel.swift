//
//  PinterestViewModel.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation
import Combine
import EasyNetwork

protocol PinterestViewModel: AnyObject {
    var dataSource: DataSource! { get set }
    var isRefreshing: Bool { get }
    
    func refresh() -> AnyPublisher<[CGFloat], Never>
    func loadImages(animatingDifferences: Bool) -> AnyPublisher<[CGFloat], Never>
    func loadImage(for index: Int) -> AnyPublisher<Data, RequestError>
}

final class PinterestViewModelImpl: PinterestViewModel {
    
    var dataSource: DataSource!
    
    private var snapshot = DataSourceSnapshot()
    private(set) var isRefreshing: Bool = false
    
    private let imagesNetworkService: ImagesNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(imagesNetworkService: ImagesNetworkService) {
        self.imagesNetworkService = imagesNetworkService
    }
    
    func loadImages(animatingDifferences: Bool = false) -> AnyPublisher<[CGFloat], Never> {
        imagesNetworkService.getImages(page: (1...10).randomElement() ?? 1)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] pictures in
                self?.configureDataSource(pictures: pictures, animatingDifferences: false)
            }, receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error \(error.debugDescription)")
                }
            })
            .map { $0.map { $0.ratio } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func loadImage(for index: Int) -> AnyPublisher<Data, RequestError> {
        imagesNetworkService.getImage(urlString: snapshot.itemIdentifiers[index].urls.small)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func refresh() -> AnyPublisher<[CGFloat], Never> {
        isRefreshing = true
        return loadImages(animatingDifferences: true)
    }
    
    //MARK: - Private methods
    
    private func configureDataSource(pictures: [PictureModel], animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(pictures)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        isRefreshing = false
    }
}
