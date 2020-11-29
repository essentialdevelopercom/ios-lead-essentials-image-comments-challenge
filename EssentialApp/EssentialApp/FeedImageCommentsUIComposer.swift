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
			let bundle = Bundle(for: FeedImageCommentsViewController.self)
			let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
			let commentsController = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
			commentsController.delegate = FeedImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
			return commentsController
		}
}

public final class FeedImageCommentsPresentationAdapter: FeedImageCommentsViewControllerDelegate {
	 let loader: FeedImageCommentsLoader
	 let url: URL

	 init(loader: FeedImageCommentsLoader, url: URL) {
		 self.loader = loader
		 self.url = url
	 }

	public func didRequestCommentsRefresh() {
		 _ = loader.load(from: url) { _ in }
	 }
 }
