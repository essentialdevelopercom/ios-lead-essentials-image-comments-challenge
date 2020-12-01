//
//  MainQueueDispatchDecorator.swift
//  EssentialApp
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(completion: @escaping () -> Void) {
		
		guard Thread.isMainThread else {
			return DispatchQueue.main.async(execute: completion)
		}
		
		completion()
	}
}

extension MainQueueDispatchDecorator: FeedImageCommentsLoader where T == FeedImageCommentsLoader {
	
	func load(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
		decoratee.load(from: url) { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
