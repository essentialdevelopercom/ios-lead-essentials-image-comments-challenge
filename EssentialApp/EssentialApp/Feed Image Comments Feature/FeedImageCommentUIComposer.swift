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
		
		let bundle = Bundle(for: FeedImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentViewController
		
		controller.delegate = presentationAdapter
		
		let feedCommentView = FeedImageCommentViewAdapter(controller: controller)
						
		presentationAdapter.presenter = FeedImageCommentLoaderPresenter(
			feedCommentView: feedCommentView, 
			loadingView: WeakRefVirtualProxy(controller))
		
		return controller
	}
}

private final class FeedImageCommentViewAdapter: FeedImageCommentView {
	private weak var controller: FeedImageCommentViewController?
	
	init(controller: FeedImageCommentViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: FeedCommentViewModel) {
		controller?.display(viewModel.comments.map { model in
			return FeedImageCommentCellController(model: model)
		})
	}
}

private final class FeedImageCommentLoaderPresentationAdapter: FeedImageCommentViewControllerDelegate {
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
