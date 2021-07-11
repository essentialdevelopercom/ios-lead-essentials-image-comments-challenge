//
//  RemoteCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteCommentsLoader = RemoteLoader<[Comment]>

public extension RemoteCommentsLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
	}
}
