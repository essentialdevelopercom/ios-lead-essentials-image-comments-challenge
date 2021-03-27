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
		
		private struct ImageCommentTaskSpy: FeedImageCommentsLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentRequests = [(imageID: String, completion: (FeedImageCommentsLoader.Result) -> Void)]()
		
		private(set) var cancelledImageIDs = [String]()
		
		func loadImageComments(imageID: String, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
			imageCommentRequests.append((imageID, completion))
			return ImageCommentTaskSpy { [weak self] in self?.cancelledImageIDs.append(imageID) }
		}
	}
	
}
