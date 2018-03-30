import FluentMySQL
import Vapor
import Foundation

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    // This class is to return User query with only id, name and username, minus the password
    // and later, make it conform to MySQLUUIDModel
    // and conform to content so that can be returned by Vapor
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(name: String, username: String) {
            self.name = name
            self.username = username
        }
    }
}

extension User: MySQLUUIDModel { }
extension User: Migration { }
extension User: Content { }

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.creatorID)
    }
}

extension User.Public: MySQLUUIDModel {
    // this is to tell that User.Public has the same table as User
    static let entity = User.entity
}

extension User.Public: Content { }
