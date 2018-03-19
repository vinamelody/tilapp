import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let route = router.grouped("api", "categories")
        route.post(use: createHandler)
        route.get(use: getAllHandler)
        route.get(Category.parameter, use: getHandler)
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
}
extension Category: Parameter { }
