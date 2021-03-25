//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 25/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(action: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { action() }
		}
		action()
	}
}

extension MainQueueDispatchDecorator: ImageCommentLoader where T == ImageCommentLoader {
	func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
		decoratee.load(from: url) { [weak self] result in
			self?.dispatch {
				completion(result)
			}
		}
	}
}
