import UIKit

public protocol FeedCommentsViewControllerDelegate {
	func didRequestFeedCommentsRefresh()
}

public class FeedCommentsViewController: UITableViewController, FeedCommentsView, FeedCommentsLoadingView, FeedCommentsErrorView {
	
    @IBOutlet private(set) public weak var errorView: ErrorView!
    
	public var delegate: FeedCommentsViewControllerDelegate?
	
	private var tableModel = [FeedCommentViewModel]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		initializeUI()
		refresh()
	}
	
	private func initializeUI() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
	}
	
	@objc private func refresh() {
		delegate?.didRequestFeedCommentsRefresh()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let comment = tableModel[indexPath.row]
		let cell = FeedCommentCell()
		cell.authorNameLabel.text = comment.name
		cell.messageLabel.text = comment.message
		cell.dateLabel.text = comment.formattedDate
		return cell
	}
	
	public func display(_ viewModel: FeedCommentsViewModel) {
		tableModel = viewModel.comments
	}
	
	public func display(_ viewModel: FeedCommentsLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: FeedCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}
}
