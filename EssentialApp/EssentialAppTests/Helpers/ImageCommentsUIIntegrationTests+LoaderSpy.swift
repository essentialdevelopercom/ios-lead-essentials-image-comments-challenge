//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import Combine

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy {
		private(set) var requests = [PassthroughSubject<[ImageComment], Error>]()

		var loadCallCount: Int {
			requests.count
		}

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			requests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeImageCommentsLoading(at index: Int) {
			requests[index].send([])
		}

		func completeImageCommentsLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			requests[index].send(imageComments)
		}

		func completeImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			requests[index].send(completion: .failure(error))
		}
	}
}
