//
//  FeedImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 13/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedImageCommentViewModel {
	private let model: FeedImageComment
	
	public init(model: FeedImageComment) {
		self.model = model
	}
	
	public var message: String? {
		return model.message
	}
	
	public var authorName: String?  {
		return model.author
	}
}

public final class FeedImageCommentLoaderViewModel {
	public typealias Observer<T> = (T) -> Void
	
	private let feedCommentLoader: FeedImageCommentLoader
	private let url: URL
	
	public init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}

	public var onLoadingStateChange: Observer<Bool>?
	public var onFeedCommentLoad: Observer<[FeedImageComment]>?

	public func loadComments() {
		onLoadingStateChange?(true)
		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			if let comments = try? result.get() {
				self?.onFeedCommentLoad?(comments)
			}
			self?.onLoadingStateChange?(false)
		}
	}
} 
