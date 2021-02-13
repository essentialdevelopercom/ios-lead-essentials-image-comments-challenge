//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 13/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum FeedImageDataMapper {
	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(
		_ data: Data,
		from response: HTTPURLResponse
	) throws -> Data {
		guard response.isOK, !data.isEmpty else {
			throw Error.invalidData
		}

		return data
	}
}
