//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject {
	private let viewModel: ImageCommentViewModel
	private var cell: ImageCommentCell?

	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
}

extension ImageCommentCellController: UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		cell?.messageLabel.text = viewModel.message
		cell?.dateLabel.text = viewModel.date
		cell?.usernameLabel.text = viewModel.authorUserName
		return cell!
	}
}
