//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentsViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRenderedImageComments() -> Int {
        return tableView.numberOfRows(inSection: 0)
    }
    
    func comment(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedImageComments() > row else {
            return nil
        }
        let datasource = tableView.dataSource
        let index = IndexPath(row: row, section: 0)
        return datasource?.tableView(tableView, cellForRowAt: index)
    }
    
    var errorMessage: String? {
        return errorView?.message
    }
}
