//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

public final class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(commentsLoader: ImageCommentsLoader, date: @escaping () -> Date = Date.init) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsLoaderPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: commentsLoader))
		
		let imageCommentsController = makeImageCommentsViewController(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(imageCommentsController),
			loadingView: WeakRefVirtualProxy(imageCommentsController),
			errorView: WeakRefVirtualProxy(imageCommentsController),
			currentDate: date)
		
		return imageCommentsController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		commentsController.delegate = delegate
		commentsController.title = title
		return commentsController
	}
}
