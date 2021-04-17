//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
	func didRequestImage()
	func didCancelImageRequest()
}

public final class FeedImageCellController {
	public typealias ResourceViewModel = UIImage

	private let viewModel: FeedImageViewModel
	private let delegate: FeedImageCellControllerDelegate
	private var cell: FeedImageCell?
	
	public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
		self.viewModel = viewModel
		self.delegate = delegate
	}
}

extension FeedImageCellController: CellController {
	public func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		cell?.locationContainer.isHidden = !viewModel.hasLocation
		cell?.locationLabel.text = viewModel.location
		cell?.descriptionLabel.text = viewModel.description
		cell?.onRetry = delegate.didRequestImage
		delegate.didRequestImage()
		return cell!
	}

	public func preload() {
		delegate.didRequestImage()
	}

	private func releaseCellForReuse() {
		cell = nil
	}

	public func cancelLoad() {
		releaseCellForReuse()
		delegate.didCancelImageRequest()
	}
}

extension FeedImageCellController: ResourceView {
	public func display(_ viewModel: UIImage) {
		cell?.feedImageView.setImageAnimated(viewModel)
	}
}

extension FeedImageCellController: ResourceLoadingView {
	public func display(_ viewModel: ResourceLoadingViewModel) {
		cell?.feedImageContainer.isShimmering = viewModel.isLoading
	}
}

extension FeedImageCellController: ResourceErrorView {
	public func display(_ viewModel: ResourceErrorViewModel) {
		cell?.feedImageRetryButton.isHidden = viewModel.message == nil
	}
}
