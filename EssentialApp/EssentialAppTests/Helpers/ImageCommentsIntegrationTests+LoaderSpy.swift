//
//  ImageCommentsIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

extension ImageCommentsIntegrationTests {
	class LoaderSpy: ImageCommentLoader {
		private var completions = [(ImageCommentLoader.Result) -> Void]()
		
		var loadCallCount: Int {
			completions.count
		}
		
		private(set) var cancelCallCount = 0
		
		final class Task: ImageCommentLoaderTask {
			private let callback: () -> Void
			init(callback: @escaping () -> Void) {
				self.callback = callback
			}
			
			func cancel() {
				callback()
			}
		}
		
		func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			completions.append(completion)
			return Task { [weak self] in
				self?.cancelCallCount += 1
			}
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "any error", code: 0)
			completions[index](.failure(error))
		}
	}
}
