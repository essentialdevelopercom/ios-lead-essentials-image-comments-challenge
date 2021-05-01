//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the feed view")
	}

	public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: comments)
	}
}
