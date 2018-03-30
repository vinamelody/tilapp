import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("api", "users")
        route.post(use: createHandler)
        route.get(use: getAllHandler)
        route.get(User.Public.parameter, use: getHandler)
        route.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<User> {
        let user = try req.content.decode(User.self)
        let hasher = try req.make(BCryptHasher.self)
        user.password = try hasher.make(user.password)
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.Public.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameter(User.Public.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameter(User.self).flatMap(to: [Acronym].self, { user in
            return try user.acronyms.query(on: req).all()
        })
    }
}

extension User: Parameter { }
extension User.Public: Parameter {}
