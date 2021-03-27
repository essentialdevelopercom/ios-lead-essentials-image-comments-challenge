//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Eric Garlock on 3/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public class ImageCommentsUIComposer {
	
	public static func imageCommentsComposedWith(loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentLoaderPresentationAdapter(loader: loader)
		
		let controller = makeImageCommentsViewController(
			title: ImageCommentPresenter.title,
			delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentPresenter(
			commentView: WeakRefVirtualProxy(controller),
			loadingView: WeakRefVirtualProxy(controller),
			errorView: WeakRefVirtualProxy(controller))
		
		return controller
	}
	
	
	private static func makeImageCommentsViewController(title: String, delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.title = title
		controller.delegate = delegate
		return controller
	}
	
}
