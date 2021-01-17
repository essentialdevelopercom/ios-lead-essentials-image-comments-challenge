//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentsViewController {
     func simulateUserInitiatedCommentsReload() {
         refreshControl?.simulatePullToRefresh()
     }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var errorMessage: String? {
        return errorView?.message
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        return tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedCommentsViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func commentMessage(at row: Int) -> String? {
        let cell = commentView(at: row) as? FeedImageCommentCell
        return cell?.commentText
    }
    
    private var commentsSection: Int {
        return 0
    }
}
