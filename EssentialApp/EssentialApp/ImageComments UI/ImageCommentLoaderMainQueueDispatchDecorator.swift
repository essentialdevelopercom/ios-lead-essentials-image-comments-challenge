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
	
	private func dispatch(_ closure: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async(execute: closure)
		}
		
		closure()
	}
	
	func load(completion: @escaping (Result<[ImageComment], Error>) -> Void) -> ImageCommentLoaderDataTask {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
