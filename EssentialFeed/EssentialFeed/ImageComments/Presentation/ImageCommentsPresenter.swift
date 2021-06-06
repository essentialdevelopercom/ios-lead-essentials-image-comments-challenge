
import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}

	public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
		let formatter = RelativeDateTimeFormatter()
		let currentDate = Date()

		return ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(
				message: $0.message,
				date: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
				username: $0.author.username
			)
		})
	}
}
