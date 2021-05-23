//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsCellController: NSObject {
	private let viewModel: ImageCommentViewModel
	private var cell: ImageCommentCell?

	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
}

extension ImageCommentsCellController: UITableViewDataSource, UITableViewDelegate {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		cell?.usernameLabel.text = viewModel.username
		cell?.createAtLabel.text = viewModel.createdAt
		cell?.descriptionLabel.text = viewModel.message
		return cell!
	}

	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		releaseCellForReuse()
	}

	private func releaseCellForReuse() {
		cell = nil
	}
}
