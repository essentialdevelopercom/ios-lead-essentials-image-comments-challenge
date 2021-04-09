//
//  ImageCommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?

	private lazy var formattedDate = { (date: Date) -> String? in
		RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
	}

	init(controller: ImageCommentsViewController? = nil) {
		self.controller = controller
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.imageComments.map { model in
			let adapter = ImageCommentPresentationAdapter(imageComment: model)
			let view = ImageCommentCellController(delegate: adapter)

			adapter.presenter = ImageCommentPresenter(imageCommentView: WeakRefVirtualProxy(view), formattedDate: formattedDate)

			return view
		})
	}
}
