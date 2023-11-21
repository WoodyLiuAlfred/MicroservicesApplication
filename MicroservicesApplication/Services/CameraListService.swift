//
//  CameraListService.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation
import Combine

protocol CameraListServiceProtocol {
    func fetchList() -> AnyPublisher<CameraList, Error>
    func update(cameraList: CameraList)
}

struct CameraListService: CameraListServiceProtocol {
    func fetchList() -> AnyPublisher<CameraList, Error> {
        let needRemote = Int.random(in: 0...1000) % 3 == 0
        if needRemote {
            return Deferred {
                apiService.cameraList()
            }.handleEvents(receiveOutput: { [stroage] output in
                stroage.send(output)
            }).eraseToAnyPublisher()
        }
        return stroage.compactMap { $0 }.setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func update(cameraList: CameraList) {
        query.async { [stroage] in
            stroage.send(cameraList)
        }
    }
    
    let query = DispatchQueue(label: "com.CameraListService.com")
    
    let apiService: APIServiceProtocol
    
    let stroage = CurrentValueSubject<CameraList?, Never>(nil)
}
