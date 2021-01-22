//
//  CommentLoader.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoader {
	typealias Result = Swift.Result<[Comment], Error>
	func load(completion: @escaping (Result) -> Void)
}
