//
//  UserStroageProtocol.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation
import Combine

protocol UserStroageProtocol {
    func remove()
    func save(_ user: UserInfo?) throws
    func read() -> AnyPublisher<UserInfo?, Error>
}

struct UserStroage: UserStroageProtocol {
    
    func remove() {
        lock.lock(); defer { lock.unlock() }
        stroage.send(nil)
    }
    
    func save(_ user: UserInfo?) throws {
        lock.lock(); defer { lock.unlock() }
        stroage.send(user)
    }
    
    func read() -> AnyPublisher<UserInfo?, Error> {
        Future { [lock, stroage] subscriber in
            lock.lock(); defer { lock.unlock() }
            let user = stroage.value
            subscriber(.success(user))
        }.eraseToAnyPublisher()
    }
    
    let stroage = CurrentValueSubject<UserInfo?, Never>(nil)
    
    private let lock = NSRecursiveLock()
}

struct UserInfo {
    var token: String
    var refreshToken: String
    let userId: String
}

extension UserInfo {
    static var `test`: Self {
        .init(token: "just-test-token", refreshToken: "show-me-the-money", userId: "123456")
    }
}
