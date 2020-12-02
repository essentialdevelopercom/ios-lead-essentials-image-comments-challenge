//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Rakesh Ramamurthy on 02/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
import UIKit

class ImageCommentsUIComposer {
	static func imageCommentsComposeWith(commentsLoader: ImageCommentsLoader, url: URL, date: Date = Date()) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
		commentsController.delegate = presentationAdapter
		let presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			errorView: WeakRefVirtualProxy(commentsController),
			currentDate: date
		)
		presentationAdapter.presenter = presenter
		return commentsController
	}
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	var presenter: ImageCommentsPresenter?
	let loader: ImageCommentsLoader
	let url: URL

	init(loader: ImageCommentsLoader, url: URL) {
		self.loader = loader
		self.url = url
	}

	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		_ = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoading(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoading(with: error)
			}
		}
	}
}
