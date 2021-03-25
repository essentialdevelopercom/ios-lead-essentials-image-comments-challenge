//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(
			url: url,
			loader: MainQueueDispatchDecorator(decoratee: loader)
		)
		let controller = ImageCommentsViewController.makeWith(title: Localized.ImageComments.title)
		
		let imageCommentsListView = ImageCommentsAdapter(
			controller: controller,
			currentDate: currentDate
		)
		
		let refreshController = controller.refreshController!
		refreshController.delegate = presentationAdapter
		
		let presenter = ImageCommentsListPresenter(
			loadingView: WeakReferenceVirtualProxy(refreshController),
			commentsView: imageCommentsListView,
			errorView: WeakReferenceVirtualProxy(refreshController)
		)
		presentationAdapter.presenter = presenter
		
		return controller
	}
}

private extension ImageCommentsViewController {
	static func makeWith(title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.title = title
		return controller
	}
}

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(action: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { action() }
		}
		action()
	}
}

extension MainQueueDispatchDecorator: ImageCommentLoader where T == ImageCommentLoader {
	func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
		decoratee.load(from: url) { [weak self] result in
			self?.dispatch {
				completion(result)
			}
		}
	}
}
