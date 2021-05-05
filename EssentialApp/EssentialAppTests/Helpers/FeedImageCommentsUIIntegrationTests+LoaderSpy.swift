//
//  FeedImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {
	
	class LoaderSpy: FeedImageCommentLoader {
		
		private class TaskWrap: FeedImageCommentLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}
		
		private(set) var cancelledRequests = 0
		private var commentsRequests = [(FeedImageCommentLoader.Result) -> Void]()
		
		var commentsCallCount: Int {
			commentsRequests.count
		}
		
		
		func completeCommentsLoading(with comments: [FeedComment] = [], at index: Int = 0) {
			commentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			commentsRequests[index](.failure(error))
		}

		func load(completion: @escaping (FeedImageCommentLoader.Result) -> Void) -> FeedImageCommentLoaderTask {
			commentsRequests.append(completion)
			return TaskWrap { [weak self] in
				self?.cancelledRequests += 1
			}
		}
	}
}
