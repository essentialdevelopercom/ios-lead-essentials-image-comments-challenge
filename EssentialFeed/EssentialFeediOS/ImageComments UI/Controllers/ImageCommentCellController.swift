
import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject {
	private let viewModel: ImageCommentViewModel

	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
}

extension ImageCommentCellController: UITableViewDataSource, UITableViewDelegate {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.labelUsername.text = viewModel.username
		cell.labelDate.text = viewModel.date
		cell.labelMessage.text = viewModel.message
		return cell
	}
}
