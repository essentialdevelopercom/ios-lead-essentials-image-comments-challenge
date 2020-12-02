//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Rakesh Ramamurthy on 02/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public enum EssentialFeedEndpoint {
	public typealias ImageUUID = String

	case comments(for: ImageUUID)

	public func url() -> URL {
		switch self {
		case let .comments(uuid):
			return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(uuid)/comments")!
		}
	}
}
