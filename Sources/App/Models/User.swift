//
//  User.swift
//  App
//
//  Created by Spencer Curtis on 4/16/19.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class User: PostgreSQLModel {
    var id: Int?
    var username: String
    var password: String
    
    init(id: Int? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    
}

final class PublicUser: Codable {
    var id: Int?
    var username: String
    
    init(id: Int?, username: String) {
        self.id = id
        self.username = username
    }
}
extension PublicUser: Content {
    
}

extension User: Content {}
extension User: Migration {}
extension User: Parameter {}


//final class User: Codable {
//    var id: UUID?
//    var username: String
//    var password: String
//
//    init(username: String, password: String) {
//        self.username = username
//        self.password = password
//    }
//
//    final class Public: Codable {
//        var id: UUID?
//        var username: String
//
//        init(id: UUID?, username: String) {
//            self.id = id
//            self.username = username
//        }
//    }
//}
//
//extension User: PostgreSQLUUIDModel {}
//extension User: Content {}
//
//extension User: Migration {
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) { builder in
//            try addProperties(to: builder)
//            builder.unique(on: \.username)
//        }
//    }
//}
//
//extension User: Parameter {}
//extension User.Public: Content {}
//
extension User {
    func convertToPublic() -> PublicUser {
        return PublicUser(id: id, username: username)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<PublicUser> {
        return self.map(to: PublicUser.self) { user in
            return user.convertToPublic()
        }
    }
}
//
extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}
//
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
