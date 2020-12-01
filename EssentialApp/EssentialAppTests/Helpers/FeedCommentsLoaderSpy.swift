//
//  FeedCommentsLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class FeedCommentsLoaderSpy: FeedImageCommentsLoader {
   var loadCommentsCallCount: Int {
	   return commentRequests.count
   }
   
   private(set) var cancelledRequestURLs = [URL]()
   
   private var commentRequests = [(url: URL, completion: (FeedImageCommentsLoader.Result) -> Void)]()
   
   var loadedImageURLs: [URL] {
	   return commentRequests.map { $0.url }
   }
   
   private struct TaskSpy: FeedImageCommentsLoaderTask {
	   let cancelCallback: () -> Void
	   func cancel() {
		   cancelCallback()
	   }
   }
   
   func load(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
	   commentRequests.append((url, completion))
	   return TaskSpy { [weak self] in self?.cancelledRequestURLs.append(url) }
   }
   
   func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
	   commentRequests[index].completion(.success(comments))
   }
   
   func completeCommentsLoading(with error: Error, at index: Int = 0) {
	   commentRequests[index].completion(.failure(error))
   }
}
