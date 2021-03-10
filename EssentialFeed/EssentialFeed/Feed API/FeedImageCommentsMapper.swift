//
//  FeedImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class FeedImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImageCommentItem]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImageCommentItem] {
		guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedImageCommentsLoader.Error.invalidData
		}
		
		return root.items
	}
}
