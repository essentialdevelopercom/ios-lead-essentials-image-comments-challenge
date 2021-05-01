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
		let formatter = RelativeDateTimeFormatter()

		return ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(message: $0.message,
			                      createdAt: formatter.localizedString(for: $0.createdAt, relativeTo: Date()),
			                      username: $0.username)
		})
	}
}
