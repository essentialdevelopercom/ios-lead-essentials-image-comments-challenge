//
//  FeedImageCommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Ivan Ornes on 18/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsViewAdapter: FeedImageCommentsView {
	private weak var controller: FeedImageCommentsViewController?
	private let formatter: RelativeDateTimeFormatter
	
	init(controller: FeedImageCommentsViewController, formatter: RelativeDateTimeFormatter) {
		self.controller = controller
		self.formatter = formatter
	}
	
	func display(_ viewModel: FeedImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { model -> FeedImageCommentCellController in
			let adapter = FeedImageCommentsDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCommentCellController>>(model: model)
			
			let view = FeedImageCommentCellController(delegate: adapter)
			adapter.presenter = FeedImageCommentPresenter(view: WeakRefVirtualProxy(view), formatter: formatter)
			
			return view
		})
	}
}