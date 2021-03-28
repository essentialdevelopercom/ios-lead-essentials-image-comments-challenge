//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class ImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		guard response.isOK else {
			throw RemoteCommentsLoader.Error.invalidData
		}
		
		do {
			let jsonDecoder = JSONDecoder()
			jsonDecoder.dateDecodingStrategy = .iso8601
			let root = try jsonDecoder.decode(Root.self, from: data)
			return root.items
		} catch {
			throw RemoteCommentsLoader.Error.invalidData
		}
	}
}
