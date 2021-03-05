//
//  RemoteFeedImageComment.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedImageComment: Decodable {
	public struct Author: Decodable {
		let username: String
	}
	
	let id: UUID
	let message: String
	let createdAt: String
	let author: Author
}
