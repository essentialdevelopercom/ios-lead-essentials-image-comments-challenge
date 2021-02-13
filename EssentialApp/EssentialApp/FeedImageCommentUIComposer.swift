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
		let presenter = FeedImageCommentLoaderPresenter()
		let presentationAdapter = FeedImageCommentLoaderPresentationAdapter(feedCommentLoader: feedCommentLoader, presenter: presenter, url: url)
		let refreshController = FeedImageCommentRefreshController(loadComments: presentationAdapter.loadComments)
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


private final class FeedImageCommentLoaderPresentationAdapter {
	private let feedCommentLoader: FeedImageCommentLoader
	private let presenter: FeedImageCommentLoaderPresenter
	private let url: URL

	init(feedCommentLoader: FeedImageCommentLoader, presenter: FeedImageCommentLoaderPresenter, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.presenter = presenter
		self.url = url
	}

	func loadComments() {
		presenter.didStartLoadingFeed()

		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter.didFinishLoadingFeed(with: comments)

			case let .failure(error):
				self?.presenter.didFinishLoadingFeed(with: error)
			}
		}
	}
}
