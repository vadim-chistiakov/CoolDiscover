//
//  ImagesNetworkService.swift
//  PinterestCompositionalLayout
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation
import EasyNetwork
import Combine

protocol ImagesNetworkService {
    func getImages(page: Int) -> AnyPublisher<[PictureModel], RequestError>
}

final class ImagesNetworkServiceImpl: EasyNetworkClient, ImagesNetworkService {
    func getImages(page: Int) -> AnyPublisher<[PictureModel], RequestError> {
        sendRequest(
            endpoint: ImagesEndpoint.images(page: page),
            responseModelType: [PictureModel].self
        )
    }
}
