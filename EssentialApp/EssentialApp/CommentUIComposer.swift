//
//  CommentUIComposer.swift
//  EssentialApp
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class CommentUIComposer {

	private init() {}

	static func commentsComposedWith(
		loader: @escaping () -> CommentLoader.Publisher,
		currentDate: @escaping () -> Date = Date.init,
		locale: Locale = Locale.current
	) -> CommentsViewController {
		let adapter = CommentsLoaderPresentationAdapter(loader: loader)
		let controller = makeController(title: CommentsPresenter.title, delegate: adapter)
		let presenter = CommentsPresenter(
			commentView: WeakRefVirtualProxy(controller),
			loadingView: WeakRefVirtualProxy(controller),
			errorView: WeakRefVirtualProxy(controller),
			currentDate: currentDate,
			locale: locale
		)

		adapter.presenter = presenter

		return controller
	}

	private static func makeController(title: String, delegate: CommentsViewControllerDelegate) -> CommentsViewController {
		let bundle = Bundle(for: CommentsViewController.self)
		let storyboard = UIStoryboard(name: "Comments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! CommentsViewController
		controller.title = title
		controller.delegate = delegate
		return controller
	}
}

