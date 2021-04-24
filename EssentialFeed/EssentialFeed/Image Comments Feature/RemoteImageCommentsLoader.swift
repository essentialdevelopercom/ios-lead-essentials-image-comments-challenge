//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 4/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
	}
}
