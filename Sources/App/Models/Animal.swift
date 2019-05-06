import Vapor
import Authentication
import FluentSQLite

final class Animal: Content {
    let id: Int
    let name: String
    let timeSeen: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case timeSeen
        case latitude
        case longitude
        case description
        case imageURL
    }
    
    init(id: Int, name: String, timeSeen: Date, latitude: Double, longitude: Double, description: String, imageURL: String) {
        self.id = id
        self.name = name
        self.timeSeen = timeSeen
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.imageURL = imageURL
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let timeSeenInterval = try container.decode(TimeInterval.self, forKey: .timeSeen)
        let timeSeen = Date(timeIntervalSince1970: timeSeenInterval)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let description = try container.decode(String.self, forKey: .description)
        let imageURL = try container.decode(String.self, forKey: .imageURL)
        
        self.init(id: id, name: name, timeSeen: timeSeen, latitude: latitude, longitude: longitude, description: description, imageURL: imageURL)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(timeSeen.timeIntervalSince1970, forKey: .timeSeen)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(description, forKey: .description)
        try container.encode(imageURL, forKey: .imageURL)
    }
}
