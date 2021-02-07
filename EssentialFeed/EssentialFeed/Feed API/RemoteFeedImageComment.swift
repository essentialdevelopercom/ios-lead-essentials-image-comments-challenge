//
//  RemoteFeedImageComment.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 06/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedImageComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteCommentAuthor
	
	struct RemoteCommentAuthor: Decodable {
		let username: String
	}
}
