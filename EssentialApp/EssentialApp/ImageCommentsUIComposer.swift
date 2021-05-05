//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Danil Vassyakin on 4/29/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func feedCommentsComposedWith(commentLoader: @escaping () -> FeedImageCommentLoader.Publisher) -> UIViewController {
		let adapter = FeedImageCommentsPresentationAdapter(loader: commentLoader)
		let vc = feedCommentsViewController(delegate: adapter)
		
		let commentsPresenter = FeedImageCommentPresenter(
			commentsView: WeakRefVirtualProxy(vc),
			errorView: WeakRefVirtualProxy(vc),
			loadingView: WeakRefVirtualProxy(vc),
			locale: .current,
			currentDateProvider: Date.init
		)
		
		adapter.presenter = commentsPresenter
		
		return vc
	}
	
	private static func feedCommentsViewController(delegate: FeedCommentsViewControllerDelegate) -> FeedCommentsViewController {
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let vc = storyboard.instantiateViewController(identifier: "feedComments") as! FeedCommentsViewController
		vc.delegate = delegate
		vc.title = FeedImageCommentPresenter.title

		return vc
	}
	
}
