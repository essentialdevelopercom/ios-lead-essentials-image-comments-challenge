//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 10/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Swift.Error>

	@discardableResult
	func load(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
