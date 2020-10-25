//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

class ImageCommentCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel?
    @IBOutlet var createdAtLabel: UILabel?
    @IBOutlet var commentLabel: UILabel?
}

public protocol ImageCommentsViewControllerDelegate {
    func didRequestCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView {
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

    @IBAction func refresh() {
        delegate?.didRequestCommentsRefresh()
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
