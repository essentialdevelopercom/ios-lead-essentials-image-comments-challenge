//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 09.07.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		var items: [RemoteComment]
		
		var comments: [Comment] {
			items.map { Comment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: $0.author.username) }
		}
	}
	
	public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Comment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard
			isOK(response),
			let root = try? decoder.decode(Root.self, from: data)
		else {
			throw RemoteCommentsLoader.Error.invalidData
		}
		
		return root.comments
	}
	
	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200...299).contains(response.statusCode)
	}
}
