//
//  FeedImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class FeedImageCommentsPresenter {
	
	public static var title: String { NSLocalizedString(
		"FEED_COMMENTS_VIEW_TITLE",
		tableName: "FeedImageComments",
		bundle: Bundle(for: FeedImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
}
