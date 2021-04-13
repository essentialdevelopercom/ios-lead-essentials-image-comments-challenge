//
//  LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 4/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed

class LoaderSpy: ImageCommentLoader {
	private var completions = [(LoadImageCommentResult) -> Void]()
	private(set) var cancelledCompletions = [(LoadImageCommentResult) -> Void]()
	var loadCallCount: Int { return completions.count }
	
	private class TaskSpy: ImageCommentLoaderTask {
		let cancelCallback: () -> Void
		
		init(cancelCallback: @escaping () -> Void) {
			self.cancelCallback = cancelCallback
		}
		
		func cancel() {
			cancelCallback()
		}
	}
	
	func load(completion: @escaping (LoadImageCommentResult) -> Void) -> ImageCommentLoaderTask {
		completions.append(completion)
		return TaskSpy { [weak self] in
			self?.cancelledCompletions.append(completion)
		}
	}
	
	func completeCommentLoading(with imageComments: [ImageComment] = []) {
		completions[0](.success(imageComments))
	}
	
	func failedCommentLoading() {
		completions[0](.failure(anyNSError()))
	}
}
