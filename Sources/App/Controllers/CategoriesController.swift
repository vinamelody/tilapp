import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("api", "categories")
        route.post(use: createHandler)
        route.get(use: getAllHandler)
        route.get(Category.parameter, use: getHandler)
        route.get(Category.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<Category> {
        return try req.content.decode(Category.self).flatMap(to: Category.self, { category in
            return category.save(on: req)
        })
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameter(Category.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameter(Category.self).flatMap(to: [Acronym].self, { category in
            return try category.acronyms.query(on: req).all()
        })
    }
}
extension Category: Parameter { }
