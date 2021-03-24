//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy: ImageCommentsLoader {
		private struct TaskSpy: ImageCommmentsLoaderTask {
			let cancelCallback: () -> Void
			func cancel() { cancelCallback() }
		}
		
		private(set) var commentsRequestHandlers = [(ImageCommentsLoader.Result) -> Void]()
		var loadImageCommentsCallCount: Int { commentsRequestHandlers.count }
		
		private(set) var cancelledURL = [URL]()
		
		private let url: URL
		
		init(url: URL) {
			self.url = url
		}
		
		func loadImageComments(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
			commentsRequestHandlers.append(completion)
			return TaskSpy { [weak self] in
				guard let self = self else { return }
				self.cancelledURL.append(self.url)
			}
		}
		
		func completeImageCommentsLoading(at index: Int) {
			commentsRequestHandlers[index](.success([]))
		}
		
		func completeImageCommentsLoadingWithError(at index: Int) {
			commentsRequestHandlers[index](.failure(anyNSError()))
		}
		
		func completeImageCommentsLoading(with comments: [ImageComment], at index: Int) {
			commentsRequestHandlers[index](.success(comments))
		}
	}

}
