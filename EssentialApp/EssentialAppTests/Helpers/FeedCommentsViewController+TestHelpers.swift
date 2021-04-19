//
//  FeedCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/20/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedCommentsViewController {
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}
