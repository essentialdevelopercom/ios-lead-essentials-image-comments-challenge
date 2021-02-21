//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
	@IBOutlet private(set) public var locationContainer: UIView!
	@IBOutlet private(set) public var locationLabel: UILabel!
	@IBOutlet private(set) public var feedImageContainer: UIView!
	@IBOutlet private(set) public var feedImageView: UIImageView!
	@IBOutlet private(set) public var feedImageRetryButton: UIButton!
	@IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageButton: UIButton!
	
    var onRetry: (() -> Void)?
	var onTap: (() -> Void)?
	
	@IBAction private func retryButtonTapped() {
		onRetry?()
	}
	
	@IBAction private func feedImageTapped() {
		onTap?()
	}
}
