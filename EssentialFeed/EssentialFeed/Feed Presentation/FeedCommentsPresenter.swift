//
//  FeedCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedCommentsPresenter {
	
	public static var title: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedCommentsPresenter.self),
			 comment: "Title for the comments view")
	}
}
