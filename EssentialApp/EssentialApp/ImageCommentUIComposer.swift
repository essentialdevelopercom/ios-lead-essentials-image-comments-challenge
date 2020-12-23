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
		loader: @escaping () -> ImageCommentsLoader.Publisher,
		currentDate: @escaping () -> Date = Date.init,
		locale: Locale = Locale.current
	) -> ImageCommentsViewController {
		let adapter = ImageCommentsLoaderPresentationAdapter(loader: loader)
		let controller = makeController(title: ImageCommentsPresenter.title, delegate: adapter)
		let presenter = ImageCommentsPresenter(
			loadingView: WeakRefVirtualProxy(controller),
			errorView: WeakRefVirtualProxy(controller),
			commentsView: WeakRefVirtualProxy(controller),
			currentDate: currentDate,
			locale: locale
		)

		adapter.presenter = presenter

		return controller
	}

	private static func makeController(title: String, delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.title = title
		controller.delegate = delegate
		return controller
	}
}
