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
		url: URL,
		feedCommentsLoader: FeedCommentsLoader
	) -> FeedCommentsViewController {
		let presentationAdapter = FeedCommentsLoaderPresentationAdapter(url: url, feedCommentsLoader: MainQueueDispatchingFeedCommentsLoader(adaptee: feedCommentsLoader))
		
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

final class FeedCommentsLoaderPresentationAdapter: FeedCommentsViewControllerDelegate {
	private let url: URL
	private let feedCommentsLoader: FeedCommentsLoader
	var presenter: FeedCommentsPresenter?
	
	init(url: URL, feedCommentsLoader: FeedCommentsLoader) {
		self.url = url
		self.feedCommentsLoader = feedCommentsLoader
	}
	
	func didRequestFeedCommentsRefresh() {
		presenter?.didStartLoadingFeedComments()
		
		feedCommentsLoader.load(url: url) {[weak self] result in
			switch result {
			case .success(let comments):
				self?.presenter?.didFinishLoadingFeedComments(with: comments)
			case .failure(let error):
				self?.presenter?.didFinishLoadingFeedComments(with: error)
			}
		}
	}
}

final class MainQueueDispatchingFeedCommentsLoader: FeedCommentsLoader {
	private let adaptee: FeedCommentsLoader
	
	init(adaptee: FeedCommentsLoader) {
		self.adaptee = adaptee
	}
	
	func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
		adaptee.load(url: url) { result in
			if Thread.isMainThread {
				completion(result)
			}else{
				DispatchQueue.main.async {
					completion(result)
				}
			}
		}
	}
}
