//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
	@IBOutlet private(set) public var locationContainer: UIView!
	@IBOutlet private(set) public var locationLabel: UILabel!
	@IBOutlet private(set) public var feedImageContainer: UIView!
	@IBOutlet private(set) public var feedImageView: UIImageView!
	@IBOutlet private(set) public var feedImageRetryButton: UIButton!
	@IBOutlet private(set) public var descriptionLabel: UILabel!

	var onRetry: (() -> Void)?

	@IBAction private func retryButtonTapped() {
		onRetry?()
	}
}
