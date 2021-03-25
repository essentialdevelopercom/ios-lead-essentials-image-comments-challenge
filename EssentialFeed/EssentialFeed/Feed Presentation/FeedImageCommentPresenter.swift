//
//  FeedImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 25/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class FeedImageCommentPresenter<View: FeedImageCommentView> {
	private let view: View
	private let formatter: RelativeDateTimeFormatter
	
	public init(view: View, formatter: RelativeDateTimeFormatter) {
		self.view = view
		self.formatter = formatter
	}
	
	public func display(_ model: FeedImageComment) {
		let date = formatter.localizedString(for: model.createdAt, relativeTo: Date())
		let viewModel = FeedImageCommentViewModel(message: model.message,
												  creationDate: date,
												  author: model.author.username)
		view.display(viewModel)
	}
}
