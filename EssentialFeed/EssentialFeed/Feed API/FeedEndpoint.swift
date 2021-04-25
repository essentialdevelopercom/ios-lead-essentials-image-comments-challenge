//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 4/25/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum FeedEndpoint {
	case get

	public func url(baseURL: URL) -> URL {
		switch self {
		case .get:
			return baseURL.appendingPathComponent("/v1/feed")
		}
	}
}
