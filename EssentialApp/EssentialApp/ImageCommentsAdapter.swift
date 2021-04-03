//
//  ImageCommentsAdapter.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation

final class ImageCommentsAdapter: ImageCommentsListView {
	private weak var controller: ImageCommentsViewController?
	var presenter: ImageCommentsListPresenter!
	
	init(controller: ImageCommentsViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsListViewModel) {
		controller?.display(viewModel.comments.map { comment in
			let viewModel = presenter.viewModel(for: comment)
			let controller = ImageCommentsCellController(viewModel: viewModel)
			return controller
		})
	}
}
