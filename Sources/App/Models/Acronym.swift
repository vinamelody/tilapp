import FluentSQLite
import Vapor

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var creatorID: User.ID
    
    init(short: String, long: String, creatorID: User.ID) {
        self.short = short
        self.long = long
        self.creatorID = creatorID
    }
}

extension Acronym: SQLiteModel {
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    static let idKey: IDKey = \Acronym.id
}

extension Acronym: Content {}
extension Acronym: Migration {}

extension Acronym {
    var creator: Parent<Acronym, User> {
        return parent(\.creatorID)
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
