//
//  MainQueueDispatchDecorator.swift
//  EssentialApp
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

public final class MainQueueDispatchDecorator: ImageCommentsLoader {
	private let decoratee: ImageCommentsLoader
	
	public init(decoratee: ImageCommentsLoader) {
		self.decoratee = decoratee
	}
	
	private func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { completion() }
		}
		completion()
	}
	
	public func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
