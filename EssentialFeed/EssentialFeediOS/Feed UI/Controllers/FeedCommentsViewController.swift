import UIKit
import EssentialFeed

public class FeedCommentsViewController: UITableViewController {
	
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
		loader.load(url: url, completion: {[weak self] _ in
			self?.refreshControl?.endRefreshing()
		})
	}
	
	private var feedCommentsTitle: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsViewController.self),
			 comment: "Title for feed comments view")
	}
}
