//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 07/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct ImageComment {
    let id: UUID
    let message: String
    let created_at: Date
    let author: ImageCommentAuthor
}
