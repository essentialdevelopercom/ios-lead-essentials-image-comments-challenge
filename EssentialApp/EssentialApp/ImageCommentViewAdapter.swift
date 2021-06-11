//
//  ImageCommentViewAdapter.swift
//  EssentialApp
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class ImageCommentViewAdapter: ResourceView {
	private weak var controller: ListViewController?

	init(controller: ListViewController) {
		self.controller = controller
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.imageComments.map { viewModel in
			CellController(id: viewModel, ImageCommentCellController(viewModel: viewModel))
		})
	}
}
