//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(imageCommentsLoader: @escaping () -> ImageCommentsLoader.Publisher, timeFormatConfiguration: TimeFormatConfiguration = .default) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageLoader:
			imageCommentsLoader)
		
		let commentsController = makeImageCommentsViewController(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			commentsView: ImageCommentsViewAdapter(controller: commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			errorView: WeakRefVirtualProxy(commentsController),
			timeFormatConfiguration: timeFormatConfiguration)
		
		return commentsController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageController.delegate = delegate
		imageController.title = title
		return imageController
	}
}

extension TimeFormatConfiguration {
	static var `default`: TimeFormatConfiguration {
		TimeFormatConfiguration(
			relativeDate: Date.init,
			locale: .autoupdatingCurrent)
	}
}

