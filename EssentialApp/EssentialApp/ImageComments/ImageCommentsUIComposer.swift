//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class ImageCommentsUIComposer{
	static func imageCommentsComposedWith(loader: ImageCommentsLoader, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) -> ImageCommentsViewController{
		let controller = ImageCommentsViewController()
		
		let presentationAdapter = ImageCommentsLoaderPresentationAdapter(imageCommentsLoader: loader)
		
		let presenter = ImageCommentsPresenter(imageCommentsView: WeakRefVirtualProxy(controller), loadingView: WeakRefVirtualProxy(controller), errorView: WeakRefVirtualProxy(controller), currentDate: currentDate, locale: locale)
		
		controller.title = ImageCommentsPresenter.title
		controller.delegate = presentationAdapter
		
		presentationAdapter.presenter = presenter
		
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
