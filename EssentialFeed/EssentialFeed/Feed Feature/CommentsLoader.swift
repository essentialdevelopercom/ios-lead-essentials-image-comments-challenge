//
//  CommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentsLoader {
	typealias Result = Swift.Result<[Comment], Error>
	
	func load(completion: @escaping (Result) -> Void) -> Void
}
