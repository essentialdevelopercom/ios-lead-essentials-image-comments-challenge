//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIComposer{
	static func imageCommentsComposedWith(loader: @escaping () -> ImageCommentsLoader.Publisher, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) -> ImageCommentsViewController{
		
		let presentationAdapter = ImageCommentsLoaderPresentationAdapter(imageCommentsLoader: loader)
		
		let controller = makeImageCommentsViewController(delegate: presentationAdapter, title: ImageCommentsPresenter.title)
		
		let presenter = ImageCommentsPresenter(imageCommentsView: WeakRefVirtualProxy(controller), loadingView: WeakRefVirtualProxy(controller), errorView: WeakRefVirtualProxy(controller), currentDate: currentDate, locale: locale)
		
		presentationAdapter.presenter = presenter
		
		return controller
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.delegate = delegate
		controller.title = title
		return controller
	}
}
