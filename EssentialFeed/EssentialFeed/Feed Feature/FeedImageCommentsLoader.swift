//
//  FeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 9/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoaderTask {
	func cancel()
}

public protocol FeedImageCommentsLoader {
	typealias Result = Swift.Result<[FeedImageComment], Error>
	
	func loadImageComments(completion: @escaping (Result) -> Void) -> FeedImageCommentsLoaderTask
}
