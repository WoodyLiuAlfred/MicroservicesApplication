//
//  CameraServer.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation
import Combine

typealias CameraList = Int

protocol APIServiceProtocol {
    func cameraList() -> AnyPublisher<CameraList, Error>
}

struct NeedTokenAPISerivce: APIServiceProtocol {
    
    func cameraList() -> AnyPublisher<CameraList, Error> {
        toeknProvider.effective()
            .flatMap { token in
                // map request
                return Just(CameraList(0)).setFailureType(to: Error.self)
            }.eraseToAnyPublisher()
    }
    
    let toeknProvider: TokenProviderProtocol
}
