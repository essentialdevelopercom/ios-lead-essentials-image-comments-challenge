//
//  FeedImageCommentUIComposer.swift
//  EssentialApp
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentUIComposer {
	private init() {}
	
	public static func feedImageCommentComposedWith(feedCommentLoader: FeedImageCommentLoader, url: URL) -> FeedImageCommentViewController {
		let refreshController = FeedImageCommentRefreshController(feedCommentLoader: feedCommentLoader, url: url)
		let feedCommentController = FeedImageCommentViewController(refreshController: refreshController)
		
		refreshController.onRefresh = adaptFeedToImageCommentCellControllers(forwardingTo: feedCommentController, loader: feedCommentLoader)
		
		return feedCommentController
	}
	
	private static func adaptFeedToImageCommentCellControllers(forwardingTo controller: FeedImageCommentViewController, loader: FeedImageCommentLoader) -> ([FeedImageComment]) -> Void {
		return { [weak controller] comments in
			controller?.tableModel = comments.map { model in
				FeedImageCommentCellController(model: model)
			}
		}
	}
}
