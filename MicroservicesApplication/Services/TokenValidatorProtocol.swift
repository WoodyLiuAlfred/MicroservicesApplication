//
//  TokenValidatorProtocol.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation
import Combine

protocol TokenValidatorProtocol {
    func isEffective(_ string: String) -> AnyPublisher<Bool, Never>
    func exchange(refreshToken token: String) -> AnyPublisher<(refresh: String, token: String), Error>
    
}

protocol TokenProviderProtocol {
    func effective() -> AnyPublisher<String, Error>
}

struct TokenProvider: TokenValidatorProtocol {
    
    func isEffective(_ string: String) -> AnyPublisher<Bool, Never> {
        return Future {
            let bool = string.count % Int.random(in: 0...10) == 3
            $0(.success(bool))
        }.eraseToAnyPublisher()
    }
    
    func exchange(refreshToken token: String) -> AnyPublisher<(refresh: String, token: String), Error> {
        return Future {
            $0(.success((refresh: "show-me-the-money - 2", token: "just-test-token - 2")))
            
            // if faile : ServiceError.tokenIsNotVaild
        }.eraseToAnyPublisher()
    }
    
    let userStroage: UserStroageProtocol
}

extension TokenProvider: TokenProviderProtocol {
    func effective() -> AnyPublisher<String, Error> {
        userStroage.read()
            .tryMap { userInfo in
                guard let userInfo else { throw ServiceError.notLogin }
                return userInfo
            }
            .flatMap { userInfo in
                return self.isEffective(userInfo.token)
                    .flatMap { bool -> AnyPublisher<String, Error> in
                        guard !bool else { return Just(userInfo.token).setFailureType(to: Error.self).eraseToAnyPublisher() }
                        return self.exchange(refreshToken: userInfo.refreshToken)
                            .handleEvents(receiveOutput: { [userStroage] info in
                                var userInfo = userInfo
                                userInfo.refreshToken = info.refresh
                                userInfo.token = info.token
                                try? userStroage.save(userInfo)
                            })
                            .map(\.token)
                            .eraseToAnyPublisher()
                    }
            }.eraseToAnyPublisher()
    }
}
