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
		commentsController.refreshController = FeedImageCommentsRefreshController(commentsLoader: commentsLoader)
		return commentsController
	}
}
