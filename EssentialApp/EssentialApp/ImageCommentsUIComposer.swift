//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Eric Garlock on 3/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

public class ImageCommentsUIComposer {
	
	public static func imageCommentsComposedWith(loader: ImageCommentLoader) -> ImageCommentsViewController {
		let viewController = ImageCommentsViewController()
		viewController.title = ImageCommentPresenter.title
		viewController.loader = loader
		viewController.presenter = ImageCommentPresenter(
			commentView: WeakRefVirtualProxy(viewController),
			loadingView: WeakRefVirtualProxy(viewController),
			errorView: WeakRefVirtualProxy(viewController))
		return viewController
	}
	
}
