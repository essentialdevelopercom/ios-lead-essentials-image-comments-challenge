//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Cronay on 24.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
	class LoaderSpy: ImageCommentsLoader {

		var completions = [(ImageCommentsLoader.Result) -> Void]()
		var cancelCount = 0

		var loadCount: Int {
			return completions.count
		}

		private class Task: ImageCommentsLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			completions.append(completion)
			return Task { [weak self] in
				self?.cancelCount += 1
			}
		}

		func completeLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}

		func completeLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "loading error", code: 0)))
		}
	}
}
