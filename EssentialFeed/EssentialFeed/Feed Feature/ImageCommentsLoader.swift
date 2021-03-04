//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 03/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommmentsLoaderTask {
	func cancel()
}

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	func loadImageComments(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommmentsLoaderTask
}
