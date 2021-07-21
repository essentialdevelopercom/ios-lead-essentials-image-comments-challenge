//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy {
		// MARK: - ImageCommentsLoader

		private var imageCommentsRequests = [PassthroughSubject<[ImageComment], Error>]()

		var imageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			imageCommentsRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index].send(comments)
		}

		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index].send(completion: .failure(error))
		}
	}
}
