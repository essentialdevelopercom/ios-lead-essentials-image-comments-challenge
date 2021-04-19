//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(
		feedLoader: @escaping () -> FeedLoader.Publisher,
		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
		selectionHandler: @escaping (String) -> Void
	) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
		
		let feedController = makeFeedViewController(
			delegate: presentationAdapter,
			title: FeedPresenter.title)
		
		presentationAdapter.presenter = FeedPresenter(
			feedView: FeedViewAdapter(
				controller: feedController,
				selectionHandler: selectionHandler,
				imageLoader: imageLoader),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController))
		
		return feedController
	}
	
	private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = title
		return feedController
	}
	
	public static func feedCommentsComposedWith(commentLoader: @escaping () -> FeedImageCommentLoader.Publisher) -> UIViewController {
		let adapter = FeedImageCommentsPresentationAdapter(loader: commentLoader)
		let vc = feedCommentsViewController(delegate: adapter)
		
		let commentsPresenter = FeedImageCommentPresenter(
			commentsView: WeakRefVirtualProxy(vc),
			errorView: WeakRefVirtualProxy(vc),
			loadingView: WeakRefVirtualProxy(vc),
			dateFormatter: .init(),
			currentDateProvider: Date.init
		)
		
		adapter.presenter = commentsPresenter
		
		return vc
	}
	
	private static func feedCommentsViewController(delegate: FeedCommentsViewViewControllerDelegate) -> FeedCommentsViewController {
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let vc = storyboard.instantiateViewController(identifier: "feedComments") as! FeedCommentsViewController
		vc.delegate = delegate
		vc.title = FeedImageCommentPresenter.title

		return vc
	}
}
