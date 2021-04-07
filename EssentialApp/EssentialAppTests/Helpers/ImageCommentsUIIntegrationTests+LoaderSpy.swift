//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy: ImageCommentsLoader {
		
		private struct TaskSpy: ImageCommentsLoaderTask {
			let cancelCallback: () -> Void
			
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		
		private(set) var cancelledRequests = [UUID]()
		
		var loadImageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index](.failure(error))
		}
		
		@discardableResult
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			imageCommentsRequests.append(completion)
			return TaskSpy() { [weak self] in
				self?.cancelledRequests.append(UUID())
			}
		}
	}
}
