import Vapor
import Authentication
import FluentSQLite

final class Animal {
    let id: Int
    let name: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String
    
    init(id: Int, name: String, timestamp: Date, latitude: Double, longitude: Double, description: String, imageURL: String) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.imageURL = imageURL
    }
}

/// Allows `Animal` to be encoded to and decoded from HTTP messages.
extension Animal: Content { }
