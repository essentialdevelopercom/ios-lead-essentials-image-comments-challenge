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
		viewController.delegate = ImageCommentLoaderPresentationAdapter(
			loader: loader,
			presenter: ImageCommentPresenter(
				commentView: WeakRefVirtualProxy(viewController),
				loadingView: WeakRefVirtualProxy(viewController),
				errorView: WeakRefVirtualProxy(viewController)))
		
		return viewController
	}
	
	private class ImageCommentLoaderPresentationAdapter : ImageCommentsViewControllerDelegate {
		
		public var loader: ImageCommentLoader
		public var presenter: ImageCommentPresenter
		
		public init(loader: ImageCommentLoader, presenter: ImageCommentPresenter) {
			self.loader = loader
			self.presenter = presenter
		}
		
		public func didRequestImageCommentsRefresh() {
			presenter.didStartLoadingComments()
			loader.load { [weak self] result in
				switch result {
				case let .success(imageComments):
					self?.presenter.didFinishLoadingComments(with: imageComments)
					break
				case let .failure(error):
					self?.presenter.didFinishLoadingComments(with: error)
					break
				}
			}
		}
		
	}
	
}
