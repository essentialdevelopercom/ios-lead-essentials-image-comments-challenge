//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
	case get(FeedImage)

	public func url(baseURL: URL) -> URL {
		switch self {
		case .get(let image):
			return baseURL.appendingPathComponent("/v1/image/\(image.id)/comments")
		}
	}
}
