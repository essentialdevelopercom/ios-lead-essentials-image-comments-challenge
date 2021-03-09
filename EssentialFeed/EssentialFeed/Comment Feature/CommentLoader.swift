//
//  CommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public protocol CommentLoaderDataTask {
	func cancel()
}

public protocol CommentLoader {
	typealias Result = Swift.Result<[Comment], Swift.Error>
	
	func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderDataTask
}
