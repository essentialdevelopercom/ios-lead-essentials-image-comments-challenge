//
//  FeedImageCommentCellPresenter.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 14/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedCommentView {
	func display(_ model: FeedImageCommentCellViewModel)
}

public struct FeedImageCommentCellViewModel {
	public let message: String
	public let authorName: String
	public let createdAt: String
}

public final class FeedImageCommentCellPresenter {
	private let commentView: FeedCommentView
	
	public init(commentView: FeedCommentView) {
		self.commentView = commentView
	}
	
	public func displayCommentView(for model: FeedImageComment) {
		let createdAtText = FeedCommentDatePolicy.getRelativeDate(for: model.creationDate)
		commentView.display(FeedImageCommentCellViewModel(message: model.message, 
														  authorName: model.author, 
														  createdAt: createdAtText))
	}
}
