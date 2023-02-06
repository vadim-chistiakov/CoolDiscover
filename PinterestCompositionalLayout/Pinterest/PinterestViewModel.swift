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
    
    func refresh() -> AnyPublisher<[Ratioable], Never>
    func loadImages(animatingDifferences: Bool) -> AnyPublisher<[Ratioable], Never>
    func loadImage(for index: Int, inSection section: Section) -> AnyPublisher<Data, RequestError>
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
    
    func loadImages(animatingDifferences: Bool = false) -> AnyPublisher<[Ratioable], Never> {
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
//            .map { $0[($0.count/2)+1...$0.count-1] }
            .map { $0.map { $0 as Ratioable }}
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func loadImage(for index: Int, inSection section: Section) -> AnyPublisher<Data, RequestError> {
        imagesNetworkService.getImage(urlString: snapshot.itemIdentifiers(inSection: section)[index].urls.small)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func refresh() -> AnyPublisher<[Ratioable], Never> {
        isRefreshing = true
        return loadImages(animatingDifferences: true)
    }
    
    //MARK: - Private methods
    
    private func configureDataSource(pictures: [PictureModel], animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(pictures[0...9].map { $0 }, toSection: .carousel)
        snapshot.appendItems(pictures[10...19].map { $0 }, toSection: .widget)
        snapshot.appendItems(pictures[20...29].map { $0 }, toSection: .pinterest)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        isRefreshing = false
    }
}
