import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        // Originally like below but thanks to the extension, it can be shorten to return try req.leaf().render("index")
//        return try req.make(LeafRenderer.self).render("index")
        let context = IndexContent(title: "Homepage")
        return try req.leaf().render("index", context)
    }
}

extension Request {
    func leaf() throws -> LeafRenderer {
        return try self.make(LeafRenderer.self)
    }
}

struct IndexContent: Encodable {
    let title: String
}
