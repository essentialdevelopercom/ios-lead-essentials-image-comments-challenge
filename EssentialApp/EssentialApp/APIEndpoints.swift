//
//  APIEndpoints.swift
//  EssentialApp
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

private let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!


enum APIEndpoint {
	case comments(imageId: String)
	
	var url: URL {
		switch self {
		case .comments(let imageId):
			return baseURL.appendingPathComponent("v1/image/\(imageId)/comments")
		}
	}
}
