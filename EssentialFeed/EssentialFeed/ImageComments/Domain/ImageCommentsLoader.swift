//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public protocol ImageCommentsLoaderTask {
	func cancel()
}

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>

	func load(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}
