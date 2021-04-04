//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T

	init(decoratee: T) {
		self.decoratee = decoratee
	}

	func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread  else {
			return DispatchQueue.main.async(execute: completion)
		}
		completion()
	}
}

extension MainQueueDispatchDecorator: ImageCommentsLoader where T == ImageCommentsLoader {
	func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
