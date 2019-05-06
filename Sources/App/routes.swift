import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Example of configuring a controller
    let userController = UserController()
    
    try router.register(collection: userController)
}
