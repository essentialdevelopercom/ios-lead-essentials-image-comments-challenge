//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsViewModel {
	public let comments: [ImageComment]
}

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the Image Comments view")
	}

	public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: comments)
	}
}
