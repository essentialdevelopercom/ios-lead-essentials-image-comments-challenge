//
//  ImageCommentLoaderMainQueueDispatchDecorator.swift
//  EssentialApp
//
//  Created by Eric Garlock on 3/12/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class ImageCommentLoaderMainQueueDispatchDecorator : ImageCommentLoader {
	
	private let decoratee: ImageCommentLoader
	
	init(decoratee: ImageCommentLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (Result<[ImageComment], Error>) -> Void) -> ImageCommentLoaderDataTask {
		decoratee.load { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}
