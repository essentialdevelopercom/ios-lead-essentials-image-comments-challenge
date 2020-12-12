//
//  FeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoaderTask {
	func cancel()
}

public protocol FeedImageCommentsLoader: class {
	typealias Result = Swift.Result<[ImageComment], Swift.Error>
	
	func load(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageCommentsLoaderTask
}
