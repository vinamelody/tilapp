import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("api", "users")
        route.post(use: createHandler)
        route.get(use: getAllHandler)
        route.get(User.parameter, use: getHandler)
        route.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap(to: User.self, { (user) in
            return user.save(on: req)
        })
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameter(User.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameter(User.self).flatMap(to: [Acronym].self, { user in
            return try user.acronyms.query(on: req).all()
        })
    }
}

extension User: Parameter { }
