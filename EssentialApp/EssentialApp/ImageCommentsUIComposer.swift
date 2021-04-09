//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader.Publisher) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageCommentsLoader: imageCommentsLoader)

		let imageCommentsController = ImageCommentsViewController.makeWith(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title
		)

		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: ImageCommentsViewAdapter(controller: imageCommentsController),
			imageCommentsLoadingView: WeakRefVirtualProxy(imageCommentsController),
			imageCommentsErrorView: WeakRefVirtualProxy(imageCommentsController)
		)

		return imageCommentsController
	}
}

private extension ImageCommentsViewController {
	static func makeWith(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageCommentsController.delegate = delegate
		imageCommentsController.title = title
		return imageCommentsController
	}
}
