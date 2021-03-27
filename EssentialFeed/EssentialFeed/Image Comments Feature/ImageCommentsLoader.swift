//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
