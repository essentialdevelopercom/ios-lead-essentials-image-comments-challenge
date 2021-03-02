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
import Combine

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

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private var cancellable: Cancellable?
	private let loader: () -> ImageCommentsLoader.Publisher
	var presenter: ImageCommentsPresenter?
	
	init(loader: @escaping () -> ImageCommentsLoader.Publisher) {
		self.loader = loader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()
		cancellable = loader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished: break
					
				case let .failure(error):
					self?.presenter?.didFinishLoadingImageComments(with: error)
				}
			}, receiveValue: { [weak self] comments in
				self?.presenter?.didFinishLoadingImageComments(with: comments)
			})
	}
}
