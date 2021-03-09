//
//  FeedImageCommentsViewModel.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

final public class FeedImageCommentsViewModel {
	private let commentsLoader: FeedImageCommentsLoader
	
	public init(commentsLoader: FeedImageCommentsLoader) {
		self.commentsLoader = commentsLoader
	}
	
	var onChange: ((FeedImageCommentsViewModel) -> Void)?
	var onCommentsLoaded: (([FeedImageComment]) -> Void)?
	
	private(set) var isLoading: Bool = false {
		didSet { onChange?(self) }
	}
	
	func loadComments() {
		isLoading = true
		commentsLoader.load { [weak self] result in
			if let comments = try? result.get() {
				self?.onCommentsLoaded?(comments)
			}
			self?.isLoading = false
		}
	}
}
