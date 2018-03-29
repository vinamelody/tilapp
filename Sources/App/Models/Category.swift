import FluentMySQL
import Vapor

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(id: Int? = nil, name: String) {
        self.name = name
    }
}
extension Category: MySQLModel {}
extension Category: Migration {}
extension Category: Content {}

extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
}
