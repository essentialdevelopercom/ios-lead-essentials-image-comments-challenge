//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader, relativeDate: @escaping () -> Date) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageLoader: MainQueueDispatchDecorator(decoratee: imageCommentsLoader))
		
		let commentsController = makeImageCommentsViewController(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			commentsView: ImageCommentsViewAdapter(controller: commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			errorView: WeakRefVirtualProxy(commentsController),
			relativeDate: relativeDate)
		
		return commentsController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageController.delegate = delegate
		imageController.title = title
		return imageController
	}
}

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async(execute: completion)
		}
		completion()
	}
}

extension MainQueueDispatchDecorator: ImageCommentsLoader where T == ImageCommentsLoader {
	func loadImageComments(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
		decoratee.loadImageComments { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
