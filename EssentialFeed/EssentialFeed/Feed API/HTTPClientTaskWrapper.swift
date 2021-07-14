//
//  HTTPClientTaskWrapper.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 10.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class HTTPClientTaskWrapper<T>: CancelableTask {
	private var completion: ((T) -> Void)?
	
	var wrapped: HTTPClientTask?
	
	init(_ completion: @escaping (T) -> Void) {
		self.completion = completion
	}
	
	func complete(with result: T) {
		completion?(result)
	}
	
	func cancel() {
		preventFurtherCompletions()
		wrapped?.cancel()
	}
	
	private func preventFurtherCompletions() {
		completion = nil
	}
}
