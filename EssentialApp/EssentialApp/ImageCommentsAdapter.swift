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
	private let currentDate: () -> Date
	
	init(controller: ImageCommentsViewController, currentDate: @escaping () -> Date) {
		self.controller = controller
		self.currentDate = currentDate
	}
	
	func display(_ viewModel: ImageCommentsListViewModel) {
		controller?.display(viewModel.comments.map { comment in
			let presentationAdapter = ImageCommentCellPresentationAdapter(comment: comment)
			let controller = ImageCommentsCellController(delegate: presentationAdapter)
			presentationAdapter.presenter = ImageCommentPresenter(
				currentDate: currentDate,
				commentView: WeakRefVirtualProxy(controller)
			)
			return controller
		})
	}
}
