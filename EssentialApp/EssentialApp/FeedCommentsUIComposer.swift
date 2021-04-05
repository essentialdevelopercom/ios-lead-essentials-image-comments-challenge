//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedCommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(
		feedCommentsLoader: FeedCommentsLoader
	) -> FeedCommentsViewController {
		let presentationAdapter = FeedCommentsLoaderPresentationAdapter(feedCommentsLoader: MainQueueDispatchingFeedCommentsLoader(adaptee: feedCommentsLoader))
		
		let feedCommentsController = makeFeedCommentsViewController(
			delegate: presentationAdapter,
			title: FeedCommentsPresenter.title)
		
		presentationAdapter.presenter = FeedCommentsPresenter(
			feedCommentsView: WeakRefVirtualProxy(feedCommentsController),
			loadingView: WeakRefVirtualProxy(feedCommentsController),
			errorView: WeakRefVirtualProxy(feedCommentsController))
		
		return feedCommentsController
	}
	
	private static func makeFeedCommentsViewController(delegate: FeedCommentsViewControllerDelegate, title: String) -> FeedCommentsViewController {
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let feedCommentsController = storyboard.instantiateInitialViewController() as! FeedCommentsViewController
		feedCommentsController.delegate = delegate
		feedCommentsController.title = title
		return feedCommentsController
	}
}
