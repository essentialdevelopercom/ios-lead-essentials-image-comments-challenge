//
//  EssentialFeedEndpoint.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum EssentialFeedEndpoint {
	case feed
	case imageComments(id: UUID)

	public var url: URL {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

		switch self {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")

		case .imageComments(let id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}
