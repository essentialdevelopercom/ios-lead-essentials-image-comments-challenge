//
//  CommetnsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Anton Ilinykh on 14.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeediOS

extension CommentsController {
	
	var imageCommentsSection: Int { 0 }
	
	func numberOfRenderedImageComments() -> Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func imageCommentView(at: Int) -> CommentCell? {
		let index = IndexPath(row: at, section: imageCommentsSection)
		return tableView.cellForRow(at: index) as? CommentCell
	}
	
	func imageCommentMessage(at: Int) -> String? {
		return imageCommentView(at: at)?.commentLabel.text
	}
}
