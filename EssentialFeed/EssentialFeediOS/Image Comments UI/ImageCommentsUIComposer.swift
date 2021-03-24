//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(url: url, loader: loader)
		let refreshController = ImageCommentsRefreshController(delegate: presentationAdapter)
		let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
		
		let imageCommentsListView = ImageCommentsAdapter(
			controller: imageCommentsViewController,
			currentDate: currentDate
		)
		
		let presenter = ImageCommentsListPresenter(
			loadingView: WeakReferenceVirtualProxy(refreshController),
			commentsView: imageCommentsListView,
			errorView: WeakReferenceVirtualProxy(refreshController)
		)
		
		presentationAdapter.presenter = presenter
		
		return imageCommentsViewController
	}
}
