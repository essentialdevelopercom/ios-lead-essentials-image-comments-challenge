//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 09/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

extension RemoteImageCommentsLoader {
	public convenience init(
		url: URL,
		client: HTTPClient
	) {
		self.init(
			url: url,
			client: client,
			mapper: ImageCommentsMapper.map
		)
	}
}
