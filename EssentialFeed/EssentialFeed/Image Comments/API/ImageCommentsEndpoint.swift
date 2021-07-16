//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
	case get(imageID: String)

	public func url(baseURL: URL) -> URL {
		switch self {
		case .get(let imageID):
			return URL(string: baseURL.absoluteString.appending("/v1/image/\(imageID)/comments"))!
		}
	}
}
