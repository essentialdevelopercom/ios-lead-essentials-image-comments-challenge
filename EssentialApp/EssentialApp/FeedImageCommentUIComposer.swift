//
//  FeedImageCommentUIComposer.swift
//  EssentialApp
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentUIComposer {
	private init() {}
	
	public static func feedImageCommentComposedWith(feedCommentLoader: FeedImageCommentLoader, url: URL) -> FeedImageCommentViewController {
		let presenter = FeedImageCommentLoaderPresenter(feedCommentLoader: feedCommentLoader, url: url)
		let refreshController = FeedImageCommentRefreshController(presenter: presenter)
		let controller = FeedImageCommentViewController(refreshController: refreshController)
		presenter.loadingView = WeakRefVirtualProxy(refreshController)
		presenter.feedCommentView = FeedImageCommentViewAdapter(controller: controller,
																feedCommentLoader: feedCommentLoader)
		
		return controller
	}
}

private final class FeedImageCommentViewAdapter: FeedImageCommentView {
	private weak var controller: FeedImageCommentViewController?
	private let feedCommentLoader: FeedImageCommentLoader
	
	init(controller: FeedImageCommentViewController, feedCommentLoader: FeedImageCommentLoader) {
		self.controller = controller
		self.feedCommentLoader = feedCommentLoader
	}
	
	func display(_ viewModel: FeedCommentViewModel) {
		controller?.tableModel = viewModel.comments.map { model in
			FeedImageCommentCellController(viewModel: FeedImageCommentCellViewModel(model: model))
		}
	}
}
