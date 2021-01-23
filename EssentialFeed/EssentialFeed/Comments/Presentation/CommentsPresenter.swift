//
//  CommentsPresenter.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public final class CommentsPresenter {
	
	public static var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
								 tableName: "Comments",
								 bundle: Bundle(for: CommentsPresenter.self),
								 comment: "Title for Comment View")
	}
	
	public init() {}
}
