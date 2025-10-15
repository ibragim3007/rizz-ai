//
//  DialogGroupModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import Foundation
import SwiftData

@Model
final class ImageEntity {
    @Attribute(.unique) var id: String
    // Сохраняем ТОЛЬКО относительное имя файла (например, "abc.jpg")
    var localUrl: String?
    var remoteUrl: String?
    var createdAt: Date

    // обратные связи (опционально)
    @Relationship(inverse: \DialogEntity.image) var dialog: DialogEntity?
    @Relationship(inverse: \DialogGroupEntity.cover) var dialogGroup: DialogGroupEntity?

    init(id: String, localUrl: String? = nil, remoteUrl: String? = nil, createdAt: Date = .now) {
        self.id = id
        self.localUrl = localUrl
        self.remoteUrl = remoteUrl
        self.createdAt = createdAt
    }
    
    // Абсолютный URL собираем из текущего Documents + относительного имени файла.
    // При этом поддерживаем старые записи с абсолютным путём (на случай миграции):
    var localFileURL: URL? {
        guard let stored = localUrl, !stored.isEmpty else { return nil }
        let fm = FileManager.default
        
        // Если строка выглядит как абсолютный путь и файл существует — вернём как есть,
        // чтобы не ломать старые данные до миграции.
        if stored.hasPrefix("/") {
            let absolute = URL(fileURLWithPath: stored)
            if fm.fileExists(atPath: absolute.path) {
                return absolute
            }
        }
        
        // Иначе считаем, что это относительное имя файла в Documents
        if let docs = try? fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return docs.appendingPathComponent((stored as NSString).lastPathComponent)
        }
        return nil
    }
    
    var remoteHTTPURL: URL? { remoteUrl.flatMap(URL.init(string:)) }
}

@Model
final class ReplyEntity {
    @Attribute(.unique) var id: String
    var content: String
    var createdAt: Date
    var toneRaw: String
    @Relationship var dialog: DialogEntity?

    init(id: String, content: String, createdAt: Date = .now, tone: ToneTypes) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.toneRaw = tone.rawValue
    }

    var tone: ToneTypes {
        get { ToneTypes(rawValue: toneRaw) ?? .RIZZ }
        set { toneRaw = newValue.rawValue }
    }
}

@Model
final class DialogEntity {
    @Attribute(.unique) var id: String
    var userId: String
    var title: String
    var context: String?
    var summary: String?
    var elements: [String]               // поддерживается SwiftData
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ReplyEntity.dialog)
    var replies: [ReplyEntity] = []

    @Relationship(deleteRule: .cascade)
    var image: ImageEntity?

    // Specify inverse only on one side to avoid circular macro resolution.
    @Relationship
    var group: DialogGroupEntity?

    init(
        id: String,
        userId: String,
        title: String,
        context: String? = nil,
        summary: String? = nil,
        elements: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.context = context
        self.summary = summary
        self.elements = elements
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Удобства
    var primaryReply: ReplyEntity? { replies.sorted { $0.createdAt < $1.createdAt }.first }
    var tone: ToneTypes? { primaryReply?.tone }
    var displaySnippet: String {
        if let s = summary, !s.isEmpty { return s }
        if let c = context, !c.isEmpty { return c }
        return primaryReply?.content ?? ""
    }
}

@Model
final class DialogGroupEntity {
    @Attribute(.unique) var id: String
    var userId: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var pinned: Bool

    @Relationship(deleteRule: .cascade, inverse: \DialogEntity.group)
    var dialogs: [DialogEntity] = []

    @Relationship(deleteRule: .cascade)
    var cover: ImageEntity?

    init(id: String, userId: String, title: String, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.userId = userId
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pinned = false
    }
}

