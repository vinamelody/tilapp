import Vapor

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymsRoute = router.grouped("api", "acronyms")
        acronymsRoute.get(use: getAllHandler)
        acronymsRoute.post(use: createHandler)
        acronymsRoute.get(Acronym.parameter, use: getHandler)
        acronymsRoute.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoute.put(Acronym.parameter, use: updateHandler)
        acronymsRoute.get(Acronym.parameter, "creator", use: getCreatorHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        let acronym = try req.content.decode(Acronym.self).await(on: req)
        return acronym.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameter(Acronym.self)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Acronym.self).flatMap(to: HTTPStatus.self, { (acronym) in return acronym.delete(on: req).transform(to: .noContent)
        })
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameter(Acronym.self), req.content.decode(Acronym.self), { (acronym, updatedAcronym) in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        })
    }
    
    func getCreatorHandler(_ req: Request) throws -> Future<User> {
        return try req.parameter(Acronym.self).flatMap(to: User.self, { acronym in
            return acronym.creator.get(on: req)
        })
    }
}

extension Acronym: Parameter {}
