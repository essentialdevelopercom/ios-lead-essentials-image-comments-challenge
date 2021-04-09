//
//  FeedImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Ivan Ornes on 22/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentsUIComposer {
	private init() {}
	
	public static func feedImageCommentsComposedWith(
		feedImageCommentsLoader: @escaping () -> FeedImageCommentsLoader.Publisher
	) -> FeedImageCommentsViewController {
		
		let presentationAdapter = FeedImageCommentsLoaderPresentationAdapter(feedImageCommentsLoader: feedImageCommentsLoader)
		let feedImageCommentsController = makeFeedImageCommentsViewController(delegate: presentationAdapter, title: FeedImageCommentsPresenter.title)
		
		presentationAdapter.presenter = FeedImageCommentsPresenter(
			feedImageCommentsView: FeedImageCommentsViewAdapter(controller: feedImageCommentsController),
			loadingView: WeakRefVirtualProxy(feedImageCommentsController),
			errorView: WeakRefVirtualProxy(feedImageCommentsController))
		
		return feedImageCommentsController
	}
	
	private static func makeFeedImageCommentsViewController(delegate: FeedImageCommentsViewControllerDelegate, title: String) -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let feedImageCommentsController = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
		feedImageCommentsController.delegate = delegate
		feedImageCommentsController.title = title
		return feedImageCommentsController
	}
}
