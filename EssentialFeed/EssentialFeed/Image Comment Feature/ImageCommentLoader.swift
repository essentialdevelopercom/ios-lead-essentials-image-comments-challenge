//
//  ImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentLoaderTask {
	func cancel()
}

public protocol ImageCommentLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	func load(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommentLoaderTask
}
