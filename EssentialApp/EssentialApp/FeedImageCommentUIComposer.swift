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
		
		let feedCommentView = FeedImageCommentViewAdapter(controller: controller)
						
		presentationAdapter.presenter = FeedImageCommentLoaderPresenter(
			feedCommentView: feedCommentView, 
			loadingView: WeakRefVirtualProxy(refreshController))
		
		return controller
	}
}

private final class FeedImageCommentViewAdapter: FeedImageCommentView {
	private weak var controller: FeedImageCommentViewController?
	var presenter: FeedImageCommentCellPresenter?
	
	init(controller: FeedImageCommentViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: FeedCommentViewModel) {
		controller?.display(viewModel.comments.map { model in
			let view = FeedImageCommentCellController()
			self.presenter = FeedImageCommentCellPresenter(commentView: view)
			presenter?.displayCommentView(for: model)
			return view
		})
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
