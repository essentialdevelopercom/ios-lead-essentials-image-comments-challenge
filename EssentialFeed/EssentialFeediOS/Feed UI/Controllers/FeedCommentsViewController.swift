import UIKit
import EssentialFeed

public class FeedCommentsViewController: UITableViewController {
	
    @IBOutlet private(set) public weak var errorView: ErrorView!
    
    private var comments: [FeedComment] = []
	
	public var url: URL!
	public var loader: FeedCommentsLoader!
	
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
		errorView.message = nil
		refreshControl?.beginRefreshing()
		loader.load(url: url, completion: {[weak self] result in
			self?.dispatchToMainThreadOptionally {[weak self] in
				self?.handle(result: result)
			}
		})
	}
	
	private func dispatchToMainThreadOptionally(_ completion: @escaping ()->()) {
		if Thread.isMainThread {
			completion()
		}else{
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
	private func handle(result: Result<[FeedComment], Error>) {
		endRefreshing()
		configureTableOrError(result: result)
	}
	
	private func endRefreshing() {
		refreshControl?.endRefreshing()
	}
	
	private func configureTableOrError(result: Result<[FeedComment], Error>) {
		switch result {
		case .success(let loadedComments):
			comments = loadedComments
			tableView.reloadData()
		case .failure:
			errorView.message = errorText
		}
	}
	
	private var feedCommentsTitle: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsViewController.self),
			 comment: "Title for feed comments view")
	}
	
	private var errorText: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsViewController.self),
			 comment: "Error text for comments loading problem")
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
