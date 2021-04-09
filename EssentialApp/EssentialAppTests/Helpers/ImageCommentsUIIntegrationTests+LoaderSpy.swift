//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy: ImageCommentsLoader {
		private struct TaskSpy: ImageCommentsLoaderTask {
			let cancelCallback: () -> Void

			func cancel() {
				cancelCallback()
			}
		}

		private(set) var completions = [(ImageCommentsLoader.Result) -> Void]()

		private(set) var cancelledImageCommentsCompletions = [(ImageCommentsLoader.Result) -> Void]()

		var loadCallCount: Int {
			completions.count
		}

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			completions.append(completion)
			return TaskSpy { [weak self] in
				self?.cancelledImageCommentsCompletions.append(completion)
			}
		}

		func completeImageCommentsLoading(at index: Int) {
			completions[index](.success([]))
		}

		func completeImageCommentsLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(imageComments))
		}

		func completeImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			completions[index](.failure(error))
		}
	}
}
