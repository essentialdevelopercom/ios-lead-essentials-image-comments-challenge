//
//  FeedImageCommentUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 11/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentUIIntegrationTests {
	class LoaderSpy: FeedImageCommentLoader {
		
		private let url: URL
		
		init(url: URL) {
			self.url = url
		}
		
		// MARK:- FeedImageCommentLoader
		
		private struct TaskSpy: FeedImageCommentLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentRequests = [(url: URL, completion: (FeedImageCommentLoader.Result) -> Void)]()
		
		var loadedImageCommentURLs: [URL] {
			return imageCommentRequests.map { $0.url }
		}
		
		private(set) var cancelledCommentsURLs = [URL]()
				
		func loadImageCommentData(completion: @escaping (Result<[FeedImageComment], Error>) -> Void) -> FeedImageCommentLoaderTask {
			imageCommentRequests.append((url, completion))
			return TaskSpy { [weak self] in
				guard let self = self else { return }
				
				self.cancelledCommentsURLs.append(self.url) 
			}
		}
		
		func completeFeedCommentLoading(with feedComments: [FeedImageComment] = [], at index: Int = 0) {
			imageCommentRequests[index].completion(.success(feedComments))
		}
		
		func completeFeedCommentLoadingWithError(at index: Int = 0) {
			imageCommentRequests[index].completion(.failure(anyNSError()))
		}
	}
}
