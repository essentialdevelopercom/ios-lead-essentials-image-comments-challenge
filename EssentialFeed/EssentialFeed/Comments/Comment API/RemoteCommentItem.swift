//
//  RemoteCommentItem.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct RemoteCommentItem: Decodable {
	public let id: UUID
	public let message: String
	public let created_at: Date
	public let author: Author
}

