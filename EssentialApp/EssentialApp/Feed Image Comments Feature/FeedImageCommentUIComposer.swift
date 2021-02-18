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
		
		let controller = makeController(delegate: presentationAdapter, title: FeedImageCommentLoaderPresenter.title)
		
		let feedCommentView = FeedImageCommentViewAdapter(controller: controller)
						
		presentationAdapter.presenter = FeedImageCommentLoaderPresenter(
			feedCommentView: feedCommentView, 
			loadingView: WeakRefVirtualProxy(controller))
		
		return controller
	}
	
	private static func makeController(delegate: FeedImageCommentViewControllerDelegate, title: String) -> FeedImageCommentViewController {
		let bundle = Bundle(for: FeedImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedImageCommentViewController
		feedController.delegate = delegate
		feedController.title = title
		return feedController
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
