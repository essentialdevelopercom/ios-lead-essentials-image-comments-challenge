//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
import UIKit

public class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(loader: ImageCommentsLoader) -> ImageCommentsViewController {
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

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	func didRequestImageCommentsRefresh() {
		dispatchInMainQueue {
			self.presenter?.didStartLoadingImageComments()
			self.loader.load { [weak self] result in
				switch result {
				case let .success(imageComments):
					self?.presenter?.didFinishLoadingImageComments(with: imageComments)
					
				case let .failure(error):
					self?.presenter?.didFinishLoadingImageComments(with: error)
				}
			}
		}
		
	}
}

func dispatchInMainQueue(_ call: @escaping () -> Void) {
	if Thread.isMainThread {
		call()
	} else {
		DispatchQueue.main.async {
			call()
		}
	}
}
