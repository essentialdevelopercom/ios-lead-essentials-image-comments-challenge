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
	
	init(controller: FeedImageCommentsViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: FeedImageCommentsViewModel) {
		controller?.display(viewModel.comments.map {
			return FeedImageCommentCellController(viewModel: $0)
		})
	}
}
