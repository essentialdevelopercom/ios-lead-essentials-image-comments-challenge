//
//  FeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentLoaderTask {
	func cancel()
}

public protocol FeedImageCommentLoader {
	typealias Result = Swift.Result<[FeedComment], Error>
	
	func load(completion: @escaping (Result) -> Void) -> FeedImageCommentLoaderTask
}
