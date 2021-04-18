//
//  Endpoint.swift
//  EssentialApp
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

enum Endpoint {
	case feed
	case imageComments(id: String)
	
	static var baseURL: URL {
		URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/")!
	}
	
	static func url(for endpoint: Endpoint) -> URL {
		switch endpoint {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		case let .imageComments(id: id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}
