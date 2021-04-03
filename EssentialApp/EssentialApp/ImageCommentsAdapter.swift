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
	private let currentDate: () -> Date
	private weak var controller: ImageCommentsViewController?
	
	init(currentDate: @escaping () -> Date, controller: ImageCommentsViewController) {
		self.currentDate = currentDate
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsListViewModel) {
		controller?.display(viewModel.comments.map { comment in
			let viewModel = ImageCommentsListPresenter.viewModel(for: comment, currentDate: currentDate)
			let controller = ImageCommentsCellController(viewModel: viewModel)
			return controller
		})
	}
}
