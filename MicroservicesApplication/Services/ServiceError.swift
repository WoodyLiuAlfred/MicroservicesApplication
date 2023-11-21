//
//  ServiceError.swift
//  MicroservicesApplication
//
//  Created by Woody on 2023/11/21.
//

import Foundation

enum ServiceError: Int, Error {
    case notLogin = 0
    case tokenIsNotVaild = 1
}
