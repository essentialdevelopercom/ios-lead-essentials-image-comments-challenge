//
//  FeedImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(commentsLoader: FeedImageCommentsLoader) -> FeedImageCommentsController {
		let presenter = FeedImageCommentsPresenter(commentsLoader: commentsLoader)
		let refreshController = FeedImageCommentsRefreshController(loadFeed: presenter.loadComments)
		let commentsController = makeCommentsController()
		presenter.loadingView = WeakRefVirtualProxy(refreshController)
		presenter.commentsView = FeedImageCommentsAdapter(controller: commentsController)
		commentsController.refreshController = refreshController
		return commentsController
	}
	
	private static func makeCommentsController() -> FeedImageCommentsController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let commentsController = storyboard.instantiateViewController(identifier: "FeedImageCommentsController") as! FeedImageCommentsController
		return commentsController
	}
}

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedImageCommentLoadingView where T: FeedImageCommentLoadingView {
	func display(_ viewModel: FeedImageCommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

private final class FeedImageCommentsAdapter: FeedImageCommentView {
	private weak var controller: FeedImageCommentsController?
	
	init(controller: FeedImageCommentsController) {
		self.controller = controller
	}
	
	func display(_ viewModel: FeedImageCommentViewModel) {
		controller?.cellControllers = viewModel.comments.map {
			FeedImageCommentCellController(model: $0)
		}
	}
}
