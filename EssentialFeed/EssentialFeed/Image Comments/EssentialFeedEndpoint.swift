//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Rakesh Ramamurthy on 02/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public enum EssentialFeedEndpoint {
	case feed
	case comments(for: UUID)

	public func url(_ baseUrl: URL) -> URL {
		switch self {
		case .feed:
			return baseUrl.appendingPathComponent("/v1/feed")
		case let .comments(uuid):
			return baseUrl.appendingPathComponent("/v1/image/\(uuid)/comments")
		}
	}
}
