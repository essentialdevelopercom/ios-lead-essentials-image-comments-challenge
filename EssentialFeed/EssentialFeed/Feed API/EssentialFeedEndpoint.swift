//
//  EssentialFeedEndpoint.swift
//  EssentialFeed
//
//  Created by Robert Dates on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum EssentialFeedEndpoint {
	case feed
	case comments(id: UUID)

	public var url: URL {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		switch self {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		case let .comments(id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}
