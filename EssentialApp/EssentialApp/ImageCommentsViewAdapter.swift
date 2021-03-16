//
//  ImageCommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?
	
	init(controller: ImageCommentsViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsViewModel, relativeDate: @escaping () -> Date) {
		controller?.display(viewModel.comments.map { model in
			ImageCommentCellController(viewModel: {
				ImageCommentViewModel(
					authorUsername: model.author.username,
					date: model.createdAt,
					body: model.message)
			},
			relativeDate: relativeDate)
		})
	}
}
