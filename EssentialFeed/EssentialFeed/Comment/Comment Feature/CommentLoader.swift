//
//  CommentLoader.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoader {
	typealias Result = Swift.Result<[Comment], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
