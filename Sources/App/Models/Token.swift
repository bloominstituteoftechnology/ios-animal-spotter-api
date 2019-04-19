//
//  Token.swift
//  App
//
//  Created by Spencer Curtis on 4/16/19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: PostgreSQLModel {
    var id: Int?
    var token: String
    var userId: User.ID
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}
extension Token {
    var user: Parent<Token, User> {
        return parent(\.userId)
    }
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userId
    }
}

extension Token: Migration {
    //    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    //        return Database.create(self, on: connection) { builder in
    //            try addProperties(to: builder)
    //            builder.reference(from: \.userID, to: \User.id)
    //        }
    //    }
}

extension Token: Content {}

//final class Token: Codable {
//    var id: UUID?
//    var token: String
//    var userID: User.ID
//
//    init(token: String, userID: User.ID) {
//        self.token = token
//        self.userID = userID
//    }
//}
//
//extension Token: PostgreSQLUUIDModel {}
//

//
//extension Token {
//    static func generate(for user: User) throws -> Token {
//        let random = try CryptoRandom().generateData(count: 16)
//        return try Token(token: random.base64EncodedString(), userID: user.requireID())
//    }
//}
//
//extension Token: Authentication.Token {
//    static let userIDKey: UserIDKey = \Token.userID
//    typealias UserType = User
//}
//
//
//extension Token {
//    var user: Parent<Token, User> {
//        return parent(\.id)
//    }
//}
