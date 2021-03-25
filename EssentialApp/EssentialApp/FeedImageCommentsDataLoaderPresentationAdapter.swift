//
//  FeedImageCommentsDataLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Ivan Ornes on 25/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

class FeedImageCommentsDataLoaderPresentationAdapter<View: FeedImageCommentView>: FeedImageCommentCellControllerDelegate {
	
	private let model: FeedImageComment
	var presenter: FeedImageCommentPresenter<View>?
	
	init(model: FeedImageComment) {
		self.model = model
	}
	
	func didRequestImageComment() {
		presenter?.display(model)
	}
}
