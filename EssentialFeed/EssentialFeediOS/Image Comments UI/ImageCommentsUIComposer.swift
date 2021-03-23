//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presenter = ImageCommentsPresenter(url: url, loader: loader)
		let refreshController = ImageCommentsRefreshController(presenter: presenter)
		let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
		let imageCommentsView = ImageCommentsAdapter(controller: imageCommentsViewController, currentDate: currentDate)
		
		presenter.loadingView = refreshController
		presenter.errorView = refreshController
		presenter.commentsView = imageCommentsView
		
		return imageCommentsViewController
	}
}

private final class ImageCommentsAdapter: ImageCommentView {
	weak var controller: ImageCommentsViewController?
	private let currentDate: () -> Date
	
	init(controller: ImageCommentsViewController, currentDate: @escaping () -> Date) {
		self.controller = controller
		self.currentDate = currentDate
	}
	
	func display(comments: [ImageComment]) {
		controller?.tableModel = comments.map { comment in
			ImageCommentsCellController(model: comment, currentDate: currentDate)
		}
	}
}
