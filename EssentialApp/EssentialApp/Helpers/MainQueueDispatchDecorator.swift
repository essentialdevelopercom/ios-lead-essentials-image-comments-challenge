//
//  MainQueueDispatchDecorator.swift
//  EssentialApp
//
//  Created by Khoi Nguyen on 6/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class MainQueueDispatchDecorator: CommentLoader {
	private let decoratee: CommentLoader
	init(decoratee: CommentLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderTask {
		decoratee.load { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async {
					completion(result)
				}
			}
		}
	}
}
