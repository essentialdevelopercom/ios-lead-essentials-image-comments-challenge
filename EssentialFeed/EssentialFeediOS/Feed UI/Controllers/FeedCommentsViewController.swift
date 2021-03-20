import UIKit
import EssentialFeed

public class FeedCommentsViewController: UITableViewController {
	
	private var comments: [FeedComment] = []
	private var url: URL!
	private var loader: FeedCommentsLoader!
	public convenience init(url: URL, loader: FeedCommentsLoader) {
		self.init()
		self.url = url
		self.loader = loader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		initializeUI()
		refresh()
	}
	
	private func initializeUI() {
		title = feedCommentsTitle
		configureRefreshControl()
	}
	
	private func configureRefreshControl() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
	}
	
	@objc private func refresh() {
		refreshControl?.beginRefreshing()
		loader.load(url: url, completion: {[weak self] result in
			self?.refreshControl?.endRefreshing()
			if let comments = try? result.get() {
				self?.comments = comments
				self?.tableView.reloadData()
			}
		})
	}
	
	private var feedCommentsTitle: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsViewController.self),
			 comment: "Title for feed comments view")
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		comments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let comment = comments[indexPath.row]
		let cell = FeedCommentCell()
		cell.authorNameLabel.text = comment.authorName
		cell.messageLabel.text = comment.message
		return cell
	}
}
