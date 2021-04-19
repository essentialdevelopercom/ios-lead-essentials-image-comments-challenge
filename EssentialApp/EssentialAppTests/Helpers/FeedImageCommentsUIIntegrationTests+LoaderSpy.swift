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
		
		private var commentsRequests = [(FeedImageCommentLoader.Result) -> Void]()
		
		var commentsCallCount: Int {
			commentsRequests.count
		}

		func load(completion: @escaping (FeedImageCommentLoader.Result) -> Void) {
			commentsRequests.append(completion)
		}
	}
}
