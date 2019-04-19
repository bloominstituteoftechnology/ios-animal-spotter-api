import Vapor
import Authentication

/// Controls basic CRUD operations on `Animal`s.
final class AnimalController: RouteCollection {
    
    func boot(router: Router) throws {
        let animalRoutes = router.grouped("api", "animals")
        
        animalRoutes.post("new", use: createHandler)
    }
    
    /// Saves a decoded `Animal` to the database.
    func createHandler(_ req: Request) throws -> Future<Animal> {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return try req.content.decode(json: Animal.self, using: decoder).flatMap { animal in
            return animal.save(on: req)
        }
    }
}
