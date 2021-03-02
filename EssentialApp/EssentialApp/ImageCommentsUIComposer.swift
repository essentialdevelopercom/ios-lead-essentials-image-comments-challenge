//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

public class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(loader: @escaping () -> ImageCommentsLoader.Publisher) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: loader)
		
		let imageCommentsViewController = makeImageCommentsViewController(delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(imageCommentsViewController),
			loadingView: WeakRefVirtualProxy(imageCommentsViewController),
			errorView: WeakRefVirtualProxy(imageCommentsViewController)
		)
		
		return imageCommentsViewController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageCommentsController.delegate = delegate
		return imageCommentsController
	}
}
