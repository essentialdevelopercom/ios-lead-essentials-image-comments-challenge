//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 09/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
    let id: UUID
    let message: String
    let created_at: Date
    let author: ImageCommentAuthor
}

struct ImageCommentAuthor: Decodable {
    let username: String
}

