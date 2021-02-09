//
//  FeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentLoaderTask {
	func cancel()
}

public protocol FeedImageCommentLoader {
	typealias Result = Swift.Result<[FeedImageComment], Error>
	
	func loadImageCommentData(from url: URL, completion: @escaping (FeedImageCommentLoader.Result) -> Void) -> FeedImageCommentLoaderTask
}
