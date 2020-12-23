//
//  ImageCommentUIComposer.swift
//  EssentialApp
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class ImageCommentUIComposer {

	private init() {}

	static func makeUI(
		loader: ImageCommentsLoader,
		currentDate: @escaping () -> Date = Date.init,
		locale: Locale = Locale.current
	) -> ImageCommentsViewController {
		let controller = ImageCommentsViewController()
		let presenter = ImageCommentsPresenter(
			loadingView: WeakRefVirtualProxy(controller),
			errorView: WeakRefVirtualProxy(controller),
			commentsView: WeakRefVirtualProxy(controller),
			currentDate: currentDate,
			locale: locale
		)
		controller.presenter = presenter
		controller.title = ImageCommentsPresenter.title
		controller.loader = loader
		return controller
	}
}
