//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoaderTask {
	func cancel()
}

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Swift.Error>
	func load(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}
