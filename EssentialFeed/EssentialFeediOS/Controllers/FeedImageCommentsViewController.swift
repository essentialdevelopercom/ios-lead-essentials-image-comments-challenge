//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCommentsViewControllerDelegate {
    func didRequestCommentsRefresh()
}

public final class FeedImageCommentsViewController: UITableViewController {
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var tableModel = [FeedImageCommentPresenterModel]() {
        didSet { tableView.reloadData() }
    }
    
    public var delegate: FeedImageCommentsViewControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction func refresh() {
        delegate?.didRequestCommentsRefresh()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
        let model = tableModel[indexPath.row]
        cell.usernameLabel?.text = model.username
        cell.createdAtLabel?.text = model.creationTime
        cell.commentLabel?.text = model.comment
        return cell
    }
}

extension FeedImageCommentsViewController: FeedImageCommentsView {
    public func display(_ viewModel: FeedImageCommentsViewModel) {
        tableModel = viewModel.comments
    }
}

extension FeedImageCommentsViewController: FeedImageCommentsLoadingView {
    public func display(_ viewModel: FeedImageCommentsLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
extension FeedImageCommentsViewController: FeedImageCommentsErrorView {
    public func display(_ viewModel: FeedImageCommentsErrorViewModel) {
        errorView?.message = viewModel.message
    }
}
