//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ImageCommentsViewController {
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    func numberOfRenderedComments() -> Int {
        tableView.numberOfRows(inSection: commentsSection)
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func cell(for row: Int, in section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let indexPath = IndexPath(row: row, section: commentsSection)
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }

    func commentView(at row: Int) -> ImageCommentCell? {
        cell(for: row, in: commentsSection) as? ImageCommentCell
    }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.commentText
    }

    var commentsSection: Int { 0 }

    var errorMessage: String? {
        errorView?.message
    }
}
