//
//  FeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoader {
	typealias Result = Swift.Result<[FeedImageComment], Error>
	
	func load(completion: @escaping (Error) -> Void) -> Void
}
