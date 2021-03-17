//
//  ImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

protocol ImageCommentLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
