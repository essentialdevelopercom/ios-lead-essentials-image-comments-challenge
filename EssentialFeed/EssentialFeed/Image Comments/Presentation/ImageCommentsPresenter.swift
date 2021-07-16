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
}
