//
//  CommentLoader.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentLoader {
	typealias LoadImageCommentResult = Swift.Result<[ImageComment], Error>
	
	func load(completion: @escaping (LoadImageCommentResult) -> Void)
}
