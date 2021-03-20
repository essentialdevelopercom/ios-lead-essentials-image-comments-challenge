//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedCommentCell: UITableViewCell {
	
	let authorNameLabel = UILabel()
	let messageLabel = UILabel()
	let dateLabel = UILabel()
	
	public var authorName: String? {
		return authorNameLabel.text
	}
	
	public var message: String? {
		return messageLabel.text
	}
	
	public var dateText: String? {
		return dateLabel.text
	}
}
