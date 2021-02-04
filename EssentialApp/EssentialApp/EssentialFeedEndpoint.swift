//
//  EssentialFeedEndpoint.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

enum EssentialFeedEndpoint{
	case feed
	case imageComments(id: UUID)
	
	var url: URL {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		switch self {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		case .imageComments(let id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}
