//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}

	public static func map(_ comments: [ImageComment], currentDate: Date = Date(), calendar: Calendar = Calendar(identifier: .gregorian), locale: Locale = .current) -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: comments.map { comment in
			let formatter = RelativeDateTimeFormatter()
			formatter.calendar = calendar
			formatter.locale = locale

			return ImageCommentViewModel(message: comment.message, date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate), username: comment.username)
		})
	}
}
