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
    func getImage(urlString: String) -> AnyPublisher<Data, RequestError>
}

final class ImagesNetworkServiceImpl: EasyNetworkClient, ImagesNetworkService {
    func getImages(page: Int) -> AnyPublisher<[PictureModel], RequestError> {
        sendRequest(
            endpoint: ImagesEndpoint.images(page: page),
            responseModelType: [PictureModel].self
        )
    }
    
    func getImage(urlString: String) -> AnyPublisher<Data, RequestError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: RequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .mapError { _ in .unknown("Image can't load")}
            .eraseToAnyPublisher()
    }
}
