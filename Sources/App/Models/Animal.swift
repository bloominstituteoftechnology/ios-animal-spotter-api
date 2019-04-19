import FluentPostgreSQL
import Vapor
import Authentication

final class Animal: PostgreSQLModel {
    var id: Int?
    let name: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String
}

/// Allows `Animal` to be used as a dynamic migration.
extension Animal: Migration { }

/// Allows `Animal` to be encoded to and decoded from HTTP messages.
extension Animal: Content { }
