//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
	
	class LoaderSpy {
		
		// MARK: - FeedLoader
		
		private(set) var feedRequests = [PassthroughSubject<[FeedImage], Error>]()
		
		var loadFeedCallCount: Int {
			return feedRequests.count
		}
		
		func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
			let publisher = PassthroughSubject<[FeedImage], Error>()
			feedRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
			feedRequests[index].send(feed)
		}
		
		func completeFeedLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			feedRequests[index].send(completion: .failure(error))
		}
		
		// MARK: - FeedImageDataLoader
		
		private(set) var cancelledImageURLs = [URL]()
		private(set) var feedImageRequests = [(url: URL, subject: PassthroughSubject<Data, Error>)]()
		
		var loadedImageURLs: [URL] {
			return feedImageRequests.map { $0.url }
		}
		
		func loadImageDataPublisher(url: URL) -> AnyPublisher<Data, Error> {
			let publisher = PassthroughSubject<Data, Error>()
			feedImageRequests.append((url, publisher))
			return publisher
				.handleEvents(receiveCancel: { [weak self] in self?.cancelledImageURLs.append(url) })
				.eraseToAnyPublisher()
		}

		func completeImageLoading(with data: Data = Data(), at: Int = 0) {
			feedImageRequests[at].subject.send(data)
		}

		func completeImageLoadingWithError(at: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			feedImageRequests[at].subject.send(completion: .failure(error))
		}
	}
	
}
