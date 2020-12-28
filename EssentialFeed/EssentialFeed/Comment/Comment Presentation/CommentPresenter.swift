//
//  CommentPresenter.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class CommentPresenter {
	
	public init(view: Any) {
		
	}
	
	public static var title: String {
		return NSLocalizedString("COMMENT_VIEW_TITLE",
								 tableName: "Comment",
								 bundle: Bundle(for: CommentPresenter.self),
								 comment: "Title for the comment view")
	}
}
