//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import UIKit

public final class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader)
		imageCommentsController.delegate = presentationAdapter
		let presenter = ImageCommentsPresenter(
			commentsView: WeakRefVirtualProxy(imageCommentsController),
			loadingView: WeakRefVirtualProxy(imageCommentsController),
			errorView: WeakRefVirtualProxy(imageCommentsController)
		)
		presentationAdapter.presenter = presenter
		return imageCommentsController
	}
}

private final class ImageCommentsPresentationAdapter:
	ImageCommentsViewControllerDelegate
{
	var presenter: ImageCommentsPresenter?

	private let loader: () -> AnyPublisher<[ImageComment], Error>
	
	private var cancellables = Set<AnyCancellable>()

	init(loader: @escaping () -> AnyPublisher<[ImageComment], Error>) {
		self.loader = loader
	}

	fileprivate func didRequestCommentsRefresh() {
		presenter?.didStartLoading()
		loader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [presenter] result in
				switch result {
				case let .failure(error):
					presenter?.didFinishLoading(with: error)

				case .finished:
					break
				}
			}, receiveValue: { [presenter] comments in
				presenter?.didFinishLoading(with: comments)
			})
			.store(in: &cancellables)
	}
}
