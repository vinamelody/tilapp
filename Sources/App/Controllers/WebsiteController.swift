import Vapor
import Leaf
import Foundation

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("users", User.parameter, use: userHandler)
        router.get("users", use: allUserHandler)
        router.get("categories", Category.parameter, use: categoryHandler)
        router.get("categories", use: allCategoriesHandler)
        router.get("create-acronym", use: createAcronymHandler)
        router.post("create-acronym", use: createAcronymPostHandler)
        router.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        router.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        // Originally like below but thanks to the extension, it can be shorten to return try req.leaf().render("index")
//        return try req.make(LeafRenderer.self).render("index")
        return Acronym.query(on: req).all().flatMap(to: View.self, { acronyms in
            let context = IndexContent(title: "Homepage", acronyms: acronyms.isEmpty ? nil : acronyms)
            return try req.leaf().render("index", context)
        })
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Acronym.self).flatMap(to: View.self, { acronym in
            return try acronym.creator.get(on: req).flatMap(to: View.self, { creator in
                let context = AcronymContext(title: acronym.long, acronym: acronym, creator: creator)
                return try req.leaf().render("acronym", context)
            })
        })
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(User.self).flatMap(to: View.self) { user in
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                let context = UserContext(title: user.name, user: user, acronyms: acronyms.isEmpty ? nil : acronyms)
                return try req.leaf().render("user", context)
            }
        }
    }
    
    func allUserHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self, { users in
            let context = AllUsersContext(title: "All Users", users: users.isEmpty ? nil : users)
            return try req.leaf().render("users", context)
        })
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Category.self).flatMap(to: View.self) { category in
            return try category.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                let context = CategoryContext(title: category.name, acronyms: acronyms.isEmpty ? nil : acronyms)
                return try req.leaf().render("category", context)
            }
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        return Category.query(on: req).all().flatMap(to: View.self, { categories in
            let context = AllCategoriesContext(title: "All Categories", categories: categories.isEmpty ? nil : categories)
            return try req.leaf().render("categories", context)
        })
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self, { users in
            let context = CreateAcronymContext(title: "Create An Acronym", users: users)
            return try req.leaf().render("createAcronym", context)
        })
    }
    
    func createAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(AcronymPostData.self).flatMap(to: Response.self, { data in
            let acronym = Acronym(short: data.acronymShort, long: data.acronymLong, creatorID: data.creator)
            return acronym.save(on: req).map(to: Response.self) { acronym in
                guard let id = acronym.id else {
                    // potentially failed saving the acronym, redirect to home
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        })
    }
    
    func editAcronymHandler(_ req: Request) -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            return try req.parameter(Acronym.self).flatMap(to: View.self) { acronym in
                let context = EditAcronymContext(title: "Edit Acronym", acronym: acronym, users: users.isEmpty ? nil : users)
                return try req.leaf().render("createAcronym", context)
            }
        }
    }
    
    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameter(Acronym.self), req.content.decode(AcronymPostData.self), { (acronym, data) in
            acronym.short = data.acronymShort
            acronym.long = data.acronymLong
            acronym.creatorID = data.creator
            
            return acronym.save(on: req).map(to: Response.self) { acronym in
                guard let id = acronym.id else {
                    // Similar like creating acro
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        })
    }
    
    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameter(Acronym.self).flatMap(to: Response.self) { acronym in
            return acronym.delete(on: req).transform(to: req.redirect(to: "/"))
        }
    }
}

extension Request {
    func leaf() throws -> LeafRenderer {
        return try self.make(LeafRenderer.self)
    }
}

struct IndexContent: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let creator: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]?
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]?
}

struct CategoryContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AllCategoriesContext: Encodable {
    let title: String
    let categories: [Category]?
}

struct CreateAcronymContext: Encodable {
    let title: String
    let users: [User]?
}

struct AcronymPostData: Content {
    static var defaultMediaType = MediaType.urlEncodedForm
    let acronymLong: String
    let acronymShort: String
    let creator: UUID
}

struct EditAcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let users: [User]?
    // add this so that we can return the same template as create
    let editing = true
}
