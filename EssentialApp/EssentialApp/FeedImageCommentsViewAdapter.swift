//
//  FeedImageCommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Ivan Ornes on 18/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsViewAdapter: FeedImageCommentsView {
	private weak var controller: FeedImageCommentsViewController?
	private let formatter: RelativeDateTimeFormatter
	
	init(controller: FeedImageCommentsViewController, formatter: RelativeDateTimeFormatter) {
		self.controller = controller
		self.formatter = formatter
	}
	
	func display(_ viewModel: FeedImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { model -> FeedImageCommentCellController in
			let cell = FeedImageCommentCellController(delegate: self)
			let date = formatter.localizedString(for: model.createdAt, relativeTo: Date())
			cell.display(FeedImageCommentViewModel(message: model.message,
												   creationDate: date,
												   author: model.author.username))
			return cell
		})
	}
}

extension FeedImageCommentsViewAdapter: FeedImageCommentCellControllerDelegate {
	func didRequestImageComment() {
	}
}
