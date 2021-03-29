//
//  ImageCommentsIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

extension ImageCommentsIntegrationTests {
	class LoaderSpy: ImageCommentLoader {
		private var messages = [(url: URL, completion: (ImageCommentLoader.Result) -> Void)]()
		
		private var completions: [(ImageCommentLoader.Result) -> Void] {
			messages.map { $0.completion }
		}
		
		var requestedURLs: [URL] {
			messages.map { $0.url }
		}
		
		var cancelledURLs = [URL]()
		
		final class Task: ImageCommentLoaderTask {
			private let callback: () -> Void
			init(callback: @escaping () -> Void) {
				self.callback = callback
			}
			
			func cancel() {
				callback()
			}
		}
		
		func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			messages.append((url, completion))
			return Task { [weak self] in
				self?.cancelledURLs.append(url)
			}
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "any error", code: 0)
			completions[index](.failure(error))
		}
	}
}
