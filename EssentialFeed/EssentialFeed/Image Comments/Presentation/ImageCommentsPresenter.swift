//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: .init(for: ImageCommentsPresenter.self),
			comment: "title for image comments view")
	}

	public static func map(_ comments: [ImageComment], currentDate: Date = Date(), calendar: Calendar = .current, locale: Locale = .current) -> ImageCommentsViewModel {
		let formatter = RelativeDateTimeFormatter()
		formatter.calendar = calendar
		formatter.locale = locale

		return ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(
				username: $0.username,
				createdAt: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
				message: $0.message
			) })
	}
}

public struct ImageCommentsViewModel {
	public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
	public let username: String
	public let createdAt: String
	public let message: String

	public init(username: String, createdAt: String, message: String) {
		self.username = username
		self.createdAt = createdAt
		self.message = message
	}
}
