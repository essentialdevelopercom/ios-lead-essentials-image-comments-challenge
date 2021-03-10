//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 21/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoaderTask {
	func cancel()
}

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	@discardableResult
	func load(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}
