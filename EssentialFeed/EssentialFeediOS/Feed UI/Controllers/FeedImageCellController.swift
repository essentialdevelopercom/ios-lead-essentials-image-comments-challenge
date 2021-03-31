//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
	func didRequestImage()
	func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
	private let cellControllerDelegate: FeedImageCellControllerDelegate
	private let selectionHandler: () -> Void
	private var cell: FeedImageCell?
	
	public init(cellControllerDelegate: FeedImageCellControllerDelegate, selectionHandler: @escaping () -> Void) {
		self.cellControllerDelegate = cellControllerDelegate
		self.selectionHandler = selectionHandler
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		cellControllerDelegate.didRequestImage()
		return cell!
	}
	
	func preload() {
		cellControllerDelegate.didRequestImage()
	}
	
	func cancelLoad() {
		releaseCellForReuse()
		cellControllerDelegate.didCancelImageRequest()
	}
	
	func didSelect() {
		selectionHandler()
	}
	
	public func display(_ viewModel: FeedImageViewModel<UIImage>) {
		cell?.locationContainer.isHidden = !viewModel.hasLocation
		cell?.locationLabel.text = viewModel.location
		cell?.descriptionLabel.text = viewModel.description
		cell?.feedImageView.setImageAnimated(viewModel.image)
		cell?.feedImageContainer.isShimmering = viewModel.isLoading
		cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
		cell?.onRetry = cellControllerDelegate.didRequestImage
	}
	
	private func releaseCellForReuse() {
		cell = nil
	}
}
