//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 07/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let author: ImageCommentAuthor
    
    public init(id: UUID, message: String, createdAt: Date, author: ImageCommentAuthor) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }
}

extension ImageComment: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case author
    }
}
