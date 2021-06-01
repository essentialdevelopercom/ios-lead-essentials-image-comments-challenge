//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy {
		private var commentsRequests = [PassthroughSubject<[ImageComment], Error>]()

		var loadCommentsCallCount: Int {
			return commentsRequests.count
		}

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			commentsRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			commentsRequests[index].send(comments)
		}

		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			commentsRequests[index].send(completion: .failure(error))
		}
	}
}
