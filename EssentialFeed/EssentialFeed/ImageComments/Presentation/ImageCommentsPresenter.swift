//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentViewModel: Hashable {
	public let message: String
	public let date: String
	public let authorUserName: String

	public init(message: String, date: String, authorUserName: String) {
		self.message = message
		self.date = date
		self.authorUserName = authorUserName
	}
}

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"COMMENTS_VIEW_TITLE",
			tableName: "Comments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comment view")
	}

	public static func map(
		_ comments: [ImageComment],
		locale: Locale = .current
	) -> ImageCommentsViewModel {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale

		return ImageCommentsViewModel(comments: comments.map({ comment in
			ImageCommentViewModel(message: comment.message, date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()), authorUserName: comment.authorUserName)
		}))
	}
}
