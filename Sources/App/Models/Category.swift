import FluentSQLite
import Vapor

final class Category: Codable {
    var id: Int?
    var name: String?
    
    init(id: Int? = nil, name: String) {
        self.name = name
    }
}
extension Category: SQLiteModel {}
extension Category: Migration {}
extension Category: Content {}
