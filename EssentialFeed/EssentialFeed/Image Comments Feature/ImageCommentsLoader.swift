//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Cronay on 20.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Swift.Error>

	func load(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}

public protocol ImageCommentsLoaderTask {
	func cancel()
}
