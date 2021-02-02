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

class ImageCommentsUIComposer{
	static func imageCommentsComposedWith(loader: ImageCommentsLoader, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) -> ImageCommentsViewController{
		
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


final class ImageCommentsLoaderPresentationAdapter: ImageCommentsControllerDelegate{
	let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	private var loaderTask:ImageCommentsLoaderTask?
	
	init(imageCommentsLoader: ImageCommentsLoader){
		self.loader = imageCommentsLoader
	}
	
	func didRequestImageCommentsRefresh() {
		self.presenter?.didStartLoadingImageComments()
				
		loaderTask = loader.load{ [weak self] result in
			switch result{
			case .success(let comments):
				self?.presenter?.didFinishLoadingImageComments(with: comments)
			case .failure(let error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
				break
			}
		}
	}
	
	func didRequestImageCommentsCancel() {
		loaderTask?.cancel()
	}
}
