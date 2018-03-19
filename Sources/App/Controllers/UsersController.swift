import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("api", "users")
        route.post(use: createHandler)
        route.get(use: getAllHandler)
        route.get(User.parameter, use: getHandler)
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
}

extension User: Parameter { }
