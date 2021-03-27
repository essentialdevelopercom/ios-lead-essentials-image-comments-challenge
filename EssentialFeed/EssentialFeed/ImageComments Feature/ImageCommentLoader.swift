//
//  ImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public protocol ImageCommentLoaderDataTask {
	func cancel()
}

public protocol ImageCommentLoader {
	typealias Result = Swift.Result<[ImageComment], Swift.Error>
	
	func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderDataTask
}
