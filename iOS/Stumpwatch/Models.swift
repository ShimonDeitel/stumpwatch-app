import Foundation

struct JobEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var treeLocation: String
    var workType: String
    var dateDone: String
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), treeLocation: String, workType: String, dateDone: String, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.treeLocation = treeLocation
        self.workType = workType
        self.dateDone = dateDone
        self.notes = notes
        self.createdAt = createdAt
    }
}
