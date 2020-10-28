//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import UIKit

public class ImageCommentCell: UITableViewCell {
    @IBOutlet public var usernameLabel: UILabel?
    @IBOutlet public var createdAtLabel: UILabel?
    @IBOutlet public var commentLabel: UILabel?
}

public protocol ImageCommentsViewControllerDelegate {
    func didRequestCommentsRefresh()
    func didCancelCommentsRequest()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView, ImageCommentsLoadingView {
    @IBOutlet public private(set) var errorView: ErrorView?
    public var delegate: ImageCommentsViewControllerDelegate?

    var models = [PresentableImageComment]() {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didCancelCommentsRequest()
    }

    @IBAction func refresh() {
        delegate?.didRequestCommentsRefresh()
    }

    public func display(_ viewModel: ImageCommentsLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    public func display(_ viewModel: ImageCommentsViewModel) {
        models = viewModel.comments
    }

    public func display(_ viewModel: ImageCommentsErrorViewModel) {
        errorView?.message = viewModel.message
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return models.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
        let model = models[indexPath.row]
        cell.usernameLabel?.text = model.username
        cell.createdAtLabel?.text = model.createdAt
        cell.commentLabel?.text = model.message
        return cell
    }
}
