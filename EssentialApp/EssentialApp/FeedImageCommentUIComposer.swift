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
		let presentationAdapter = FeedImageCommentLoaderPresentationAdapter(feedCommentLoader: feedCommentLoader, url: url)
		let refreshController = FeedImageCommentRefreshController(delegate: presentationAdapter)
		let controller = FeedImageCommentViewController(refreshController: refreshController)
		
		presentationAdapter.presenter = FeedImageCommentLoaderPresenter(feedCommentView: FeedImageCommentViewAdapter(controller: controller, feedCommentLoader: feedCommentLoader), loadingView: WeakRefVirtualProxy(refreshController))
		
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


private final class FeedImageCommentLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
	private let feedCommentLoader: FeedImageCommentLoader
	var presenter: FeedImageCommentLoaderPresenter?
	private let url: URL

	init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}
	
	func didRequestFeedCommentRefresh() {
		presenter?.didStartLoadingFeed()

		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingFeed(with: comments)

			case let .failure(error):
				self?.presenter?.didFinishLoadingFeed(with: error)
			}
		}
	}
}
