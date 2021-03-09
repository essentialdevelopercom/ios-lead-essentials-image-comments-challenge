//
//  FeedImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(commentsLoader: FeedImageCommentsLoader) -> FeedImageCommentsController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let commentsController = storyboard.instantiateViewController(identifier: "FeedImageCommentsController") as! FeedImageCommentsController
		let commentsViewModel = FeedImageCommentsViewModel(commentsLoader: commentsLoader)
		commentsViewModel.onCommentsLoaded = adaptCommentsToCellControllers(forwardingTo: commentsController)
		commentsController.refreshController = FeedImageCommentsRefreshController(viewModel: commentsViewModel)
		return commentsController
	}
	
	private static func adaptCommentsToCellControllers(forwardingTo controller: FeedImageCommentsController) -> (([FeedImageComment]) -> Void) {
		return { [weak controller] comments in
			controller?.cellControllers = comments.map {
				FeedImageCommentCellController(model: $0)
			}
		}
	}
}
