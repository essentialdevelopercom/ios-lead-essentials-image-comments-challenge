//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
	case get(imageID: UUID)

	public func url(baseURL: URL) -> URL {
		switch self {
		case .get(let imageID):
			return baseURL.appendingPathComponent("/v1/image/\(imageID.uuidString)/comments")
		}
	}
}
