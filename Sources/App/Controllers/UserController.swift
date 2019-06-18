//
//  UserController.swift
//  App
//
//  Created by Spencer Curtis on 4/16/19.
//

import Vapor
import Crypto
import FluentSQLite

struct UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        
        usersRoute.post("login", use: login)
        usersRoute.post("signup", use: createHandler)
        
        // tokenAuthMiddleware looks for the Authorization header
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        // guardAuthMiddleware doesn't allow a handler to run until the token middleware makes sure that a token is in the request's Authorization header.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let animalsRoute = router.grouped("api", "animals")
        let tokenAuthGroup = animalsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenAuthGroup.get("all", use: getAnimalsHandler)
        tokenAuthGroup.get(String.parameter, use: getAnimalHandler)
        tokenAuthGroup.post("new", use: addAnimalHandler)
        
//        let usersAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        usersRoute.delete("clear", use: clearUsers)
    }
    
    // The two Animal handlers won't work if I try to put them in the AnimalController. My assumption is that Vapor doesn't like having multiple instances of the token/guard auth middleware.
    
    /// Returns an array of animal names to be used in the master list view
    func getAnimalsHandler(_ req: Request) throws -> Future<[String]> {
        
        let promise = req.eventLoop.newPromise([String].self)
        
        promise.succeed(result: self.animalController.animalNames)
        
        return promise.futureResult
    }
    
    /// Returns a complete Animal object based on the name included in the URL. i.e. /api/animals/lion would return the lion Animal object.
    func getAnimalHandler(_ req: Request) throws -> Future<Animal> {
        
        let animalName = try req.parameters.next(String.self).capitalized
        
        let promise = req.eventLoop.newPromise(Animal.self)
        
        if let animal = animalController.animals.filter({$0.name == animalName}).first {
            promise.succeed(result: animal)
            return promise.futureResult
        } else {
            throw Abort(.notFound)
        }
    }
    
    func addAnimalHandler(_ req: Request) throws -> Future<HTTPResponseStatus> {
        
        return try req.content
            .decode(Animal.self)
            .flatMap({ (animal) -> EventLoopFuture<HTTPResponseStatus> in
                
                var animal = animal
                
                defer { self.animalController.animals.append(animal) }
                
                if animal.id == nil ||
                    self.animalController.animals.contains(where: { $0.id == animal.id })  {
                    
                    animal.id = self.animalController.animals.count + 1
                }
                
                let promise = req.eventLoop.newPromise(HTTPResponseStatus.self)
                promise.succeed(result: .created)
                return promise.futureResult
            })
    }
    
    /// Creates a User object and saves it to the database. Also of note is that the password is saved as a hash. This expects a User object as the body of the request
    func createHandler(_ req: Request) throws -> Future<PublicUser> {
        
        return try req.content
            .decode(User.self)
            .flatMap({ user -> Future<PublicUser> in
                
                // TODO: Figure out how to log in using the salted password hash
                //            let saltedPassword = user.password + "com.lambdaschool.AnimalSpotter" + ".\(user.username)"
                user.password = try BCrypt.hash(user.password)
                let publicUser = user.save(on: req).convertToPublic()
                return publicUser
            })
    }
    
    /// Logs in the user, and returns a token to be used for authenticating protected requests like GETting Animals. This expects a User object as the body of the request. The user must have signed up using the /api/users/signup endpoint before trying to log in.
    func login(_ req: Request) throws -> Future<Token> {
        
        return try req.content.decode(User.self).flatMap { decodedUser -> Future<Token> in
            
            return User.query(on: req)
                .filter(\.username == decodedUser.username)
                .first().flatMap { fetchedUser in
                    guard let existingUser = fetchedUser else {
                        throw Abort(HTTPStatus.notFound)
                    }
                    let hasher = try req.make(BCryptDigest.self)
                    if try hasher.verify(decodedUser.password, created: existingUser.password) {
                        let tokenString = try CryptoRandom().generateData(count: 32).base64EncodedString()
                        let token = try Token(token: tokenString, userId: existingUser.requireID())
                        return token.save(on: req)
                    } else {
                        throw Abort(HTTPStatus.unauthorized)
                    }
            }
        }
    }
    
    func clearUsers(_ req: Request) throws -> Future<HTTPResponseStatus> {
        return User.query(on: req)
            .all().flatMap { (users) -> EventLoopFuture<HTTPResponseStatus> in
                for user in users {
                    _ = user.delete(on: req)
                }
                let promise = req.eventLoop.newPromise(HTTPResponseStatus.self)
                promise.succeed(result: .ok)
                return promise.futureResult
        }
        
    }
    
    let animalController = AnimalController()
}
