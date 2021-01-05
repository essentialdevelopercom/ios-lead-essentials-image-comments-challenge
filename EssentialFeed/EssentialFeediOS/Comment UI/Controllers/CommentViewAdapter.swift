//
//  CommentViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class CommentViewAdapter: CommentView {
	private weak var controller: CommentViewController?
	
	init(controller: CommentViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: CommentViewModel) {
		controller?.tableModel = viewModel.comments.map {
			CommentCellController(model: $0)
		}
	}
}
