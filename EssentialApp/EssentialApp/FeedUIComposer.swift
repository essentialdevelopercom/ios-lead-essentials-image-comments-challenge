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
		selection: @escaping (FeedImage) -> Void
	) -> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)
		
		let feedController = makeFeedViewController(title: FeedPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource
		
		presentationAdapter.presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: imageLoader,
				selection: selection),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController),
			mapper: FeedPresenter.map)
		
		return feedController
	}
	
	private static func makeFeedViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title
		return feedController
	}
}
