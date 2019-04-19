import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Example of configuring a controller
    let animalController = AnimalController()
    let userController = UserController()
    
    try router.register(collection: animalController)
    try router.register(collection: userController)
}
