//
//  FeedImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 27/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {
	
	class LoaderSpy: FeedImageCommentsLoader {
		
		// MARK: - FeedImageCommentsLoader
		
		var loadFeedImageCommentsCallCount: Int {
			return imageCommentRequests.count
		}
		
		func completeFeedImageCommentsLoading(with feed: [FeedImageComment] = [], at index: Int = 0) {
			imageCommentRequests[index].completion(.success(feed))
		}
		
		func completeFeedImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentRequests[index].completion(.failure(error))
		}
		
		private struct ImageCommentTaskSpy: FeedImageCommentsLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentRequests = [(String, completion: (FeedImageCommentsLoader.Result) -> Void)]()
		
		private(set) var cancelledTasks = [(String, completion: (FeedImageCommentsLoader.Result) -> Void)]()
		
		func load(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
			imageCommentRequests.append(("", completion))
			return ImageCommentTaskSpy { [weak self] in self?.cancelledTasks.append(("", completion)) }
		}
	}
	
}
