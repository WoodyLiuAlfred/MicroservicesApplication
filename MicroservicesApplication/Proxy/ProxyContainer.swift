//
//  ProxyContainer.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation
import Factory

fileprivate extension Container {
    
    var userInfoStroage: UserStroageProtocol {
        return Factory(self) { UserStroage() }
            .scope(.singleton)
            .resolve()
    }
    
    var tokenService: TokenValidatorProtocol&TokenProviderProtocol {
        return Factory(self) { TokenProvider(userStroage: self.userInfoStroage) }
            .scope(.unique)
            .resolve()
    }
    
    var needVaildTokeApiService: APIServiceProtocol {
        return Factory(self) { NeedTokenAPISerivce(toeknProvider: self.tokenService) }
            .scope(.unique)
            .resolve()
    }

}

extension Container {
    
    var cameraList: CameraListServiceProtocol {
        return Factory(self) { CameraListService(apiService: needVaildTokeApiService) }
            .scope(.unique)
            .resolve()
    }
}
