//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Antonio Mayorga on 4/9/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
//	private init() {}
//	
//	public static func feedComposedWith(
//		feedLoader: @escaping () -> FeedLoader.Publisher,
//		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
//	) -> FeedViewController {
//		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
//		
//		let feedController = makeFeedViewController(
//			delegate: presentationAdapter,
//			title: FeedPresenter.title)
//		
//		presentationAdapter.presenter = FeedPresenter(
//			feedView: FeedViewAdapter(
//				controller: feedController,
//				imageLoader: imageLoader),
//			loadingView: WeakRefVirtualProxy(feedController),
//			errorView: WeakRefVirtualProxy(feedController))
//		
//		return feedController
//	}
//	
//	private static func makeImageCommentViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
//		let bundle = Bundle(for: ImageCommentViewController.self)
//		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
//		let feedController = storyboard.instantiateInitialViewController() as! ImageCommentViewController
//		feedController.delegate = delegate
//		feedController.title = title
//		return feedController
//	}
}
