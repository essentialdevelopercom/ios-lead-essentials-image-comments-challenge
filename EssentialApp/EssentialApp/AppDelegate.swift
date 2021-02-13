//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {}

enum EssentialFeedEndpoint {
	case feed
	case comments(id: UUID)

	var url: URL {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		switch self {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		case let .comments(id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}
