//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(
			url: url,
			loader: MainQueueDispatchDecorator(decoratee: loader)
		)
		let controller = ImageCommentsViewController.makeWith(title: Localized.ImageComments.title)
		let imageCommentsListView = ImageCommentsAdapter(controller: controller)
		
		let refreshController = controller.refreshController!
		refreshController.delegate = presentationAdapter
		
		let presenter = ImageCommentsListPresenter(
			currentDate: currentDate,
			loadingView: WeakRefVirtualProxy(refreshController),
			commentsView: imageCommentsListView,
			errorView: WeakRefVirtualProxy(refreshController)
		)
		presentationAdapter.presenter = presenter
		imageCommentsListView.presenter = presenter
		
		return controller
	}
}

private extension ImageCommentsViewController {
	static func makeWith(title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.title = title
		return controller
	}
}
