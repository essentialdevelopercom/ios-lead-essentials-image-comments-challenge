//
//  FeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

protocol FeedImageCommentLoader {
	typealias Result = Swift.Result<[FeedImageComment], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
