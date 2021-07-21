//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCell: UITableViewCell {
	@IBOutlet private(set) public weak var usernameLabel: UILabel!
	@IBOutlet private(set) public weak var dateLabel: UILabel!
	@IBOutlet private(set) public weak var messageLabel: UILabel!
}

public final class ImageCommentCellController: NSObject {
	private let viewModel: ImageCommentViewModel

	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
}

extension ImageCommentCellController: UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.usernameLabel.text = viewModel.username
		cell.dateLabel.text = viewModel.createdAt
		cell.messageLabel.text = viewModel.message
		return cell
	}
}
