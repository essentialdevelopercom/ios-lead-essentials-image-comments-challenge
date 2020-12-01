//
//  FeedImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import UIKit
import Foundation
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentsUIComposer {
	
	public static func imageCommentsComposeWith(commentsLoader: FeedImageCommentsLoader, url: URL) -> FeedImageCommentsViewController {
		
		let dispatchToMainCompletionLoader = MainQueueDispatchDecorator(decoratee: commentsLoader)
		let presentationAdapter = FeedImageCommentsPresentationAdapter(loader: dispatchToMainCompletionLoader, url: url)
		
		let commentsController = makeFeedImageCommentsViewController(delegate: presentationAdapter, title: FeedImageCommentsPresenter.title)
		let weakController = WeakRefVirtualProxy(commentsController)
		
		presentationAdapter.presenter = FeedImageCommentsPresenter(
			commentsView: weakController,
			loadingView: weakController,
			errorView: weakController)
		
		return commentsController
	}
	
	private static func makeFeedImageCommentsViewController(delegate: FeedImageCommentsViewControllerDelegate, title: String) -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
		commentsController.delegate = delegate
		commentsController.title = title
		return commentsController
	}
}

public final class FeedImageCommentsPresentationAdapter: FeedImageCommentsViewControllerDelegate {
	
	var presenter: FeedImageCommentsPresenter?
	private let loader: FeedImageCommentsLoader
	let url: URL
	
	init(loader: FeedImageCommentsLoader, url: URL) {
		self.loader = loader
		self.url = url
	}
	
	public func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		_ = loader.load(from: url) { [weak self] result
			in
			
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}

		}
	}
}
