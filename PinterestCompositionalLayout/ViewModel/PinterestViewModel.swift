//
//  PinterestViewModel.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation
import Combine

final class PinterestViewModel {
    
    private let imagesNetworkService: ImagesNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(imagesNetworkService: ImagesNetworkService) {
        self.imagesNetworkService = imagesNetworkService
    }
    
    func loadImages() {
        imagesNetworkService.getImages(page: 1)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { models in
                print("models:: \(models)")
            }
            .store(in: &cancellables)

    }
}
