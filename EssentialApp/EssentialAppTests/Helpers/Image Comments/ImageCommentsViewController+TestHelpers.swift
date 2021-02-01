//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

extension ImageCommentCell{
	var messageText: String?{ message.text }
	var createdAtText: String?{ createdAt.text }
	var usernameText: String?{ username.text }
}


extension ImageCommentsViewController {
	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var imageCommentsSection: Int {
		return 0
	}
}
