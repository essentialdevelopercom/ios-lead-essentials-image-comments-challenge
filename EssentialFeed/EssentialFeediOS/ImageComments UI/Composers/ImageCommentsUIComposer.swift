//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presenter = ImageCommentsPresenter(imageCommentsLoader: imageCommentsLoader)
		let refreshController = ImageCommentsRefreshViewController(presenter: presenter)
		let imageCommentsController = ImageCommentsViewController(refreshController: refreshController)
		presenter.imageCommentsLoadingView = WeakRefVirtualProxy(refreshController)
		presenter.imageCommentsView = ImageCommentsViewAdapter(controller: imageCommentsController, imageCommentsLoader: imageCommentsLoader)
		return imageCommentsController
	}
}

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
	func display(isLoading: Bool) {
		object?.display(isLoading: isLoading)
	}
}

private final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?
	private let imageCommentsLoader: ImageCommentsLoader

	init(controller: ImageCommentsViewController? = nil, imageCommentsLoader: ImageCommentsLoader) {
		self.controller = controller
		self.imageCommentsLoader = imageCommentsLoader
	}

	func display(_ imageComments: [ImageComment]) {
		controller?.tableModel = imageComments.map { model in
			ImageCommentCellController(viewModel: ImageCommentViewModel(model: model))
		}
	}
}
