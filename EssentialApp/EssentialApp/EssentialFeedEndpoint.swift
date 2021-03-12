//
//  EssentialFeedEndpoint.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct EssentialFeedAPI {
	enum Endpoint {
		case feed
		case imageComments(id: UUID)
		
		var path: String {
			switch self {
			case .feed:
				return "v1/feed"
			case .imageComments(let id):
				return "v1/image/\(id)/comments"
			}
		}
	}
	
	let baseURL: URL
	
	func url(for endpoint: EssentialFeedAPI.Endpoint) -> URL {
		baseURL.appendingPathComponent(endpoint.path)
	}
}
