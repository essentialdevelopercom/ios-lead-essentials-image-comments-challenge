//
//  ImageCommentViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 4/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeediOS

extension ImageCommentViewController {
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var isShowingErrorView: Bool {
		return errorView?.isHidden != true
	}
	
	func numberOfRenderedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: imageCommentSections)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentSections)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var imageCommentSections: Int {
		return 0
	}
}
