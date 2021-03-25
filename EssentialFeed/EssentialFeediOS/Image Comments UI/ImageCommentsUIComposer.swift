//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(url: url, loader: loader)
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		
		let imageCommentsViewController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageCommentsViewController.title = ImageCommentsListPresenter.title
		
		let imageCommentsListView = ImageCommentsAdapter(
			controller: imageCommentsViewController,
			currentDate: currentDate
		)
		
		let refreshController = imageCommentsViewController.refreshController!
		refreshController.delegate = presentationAdapter
		
		let presenter = ImageCommentsListPresenter(
			loadingView: WeakReferenceVirtualProxy(refreshController),
			commentsView: imageCommentsListView,
			errorView: WeakReferenceVirtualProxy(refreshController)
		)
		presentationAdapter.presenter = presenter
		
		return imageCommentsViewController
	}
}
