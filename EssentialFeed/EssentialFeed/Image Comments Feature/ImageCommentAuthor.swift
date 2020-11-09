//
//  FeedImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 07/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentAuthor: Equatable, Decodable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}
