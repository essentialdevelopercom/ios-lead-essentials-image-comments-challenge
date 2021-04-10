//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 10.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	private func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async(execute: completion)
		}
		
		completion()
	}
}

extension MainQueueDispatchDecorator: CommentsLoader where T == CommentsLoader {
	func load(completion: @escaping (CommentsLoader.Result) -> Void) -> CancelableTask {
		return decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
