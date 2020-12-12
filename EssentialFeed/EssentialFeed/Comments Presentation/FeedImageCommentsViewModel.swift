//
//  FeedImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentsViewModel {
	
	public let comments: [FeedImageCommentPresentingModel]
	
	public init(comments: [FeedImageCommentPresentingModel]) {
		self.comments = comments
	}
}
