//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class ImageCommentsUIComposer {
	private init() {}

	private typealias ImageCommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], ImageCommentViewAdapter>

	public static func imageCommentsComposedWith(imageCommentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: imageCommentsLoader)

		let imageCommentsController = makeImageCommentsViewController(title: ImageCommentsPresenter.title)
		imageCommentsController.onRefresh = presentationAdapter.loadResource

		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: ImageCommentViewAdapter(controller: imageCommentsController),
			loadingView: WeakRefVirtualProxy(imageCommentsController),
			errorView: WeakRefVirtualProxy(imageCommentsController),
			mapper: ImageCommentsPresenter.map)

		return imageCommentsController
	}

	private static func makeImageCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ListViewController
		imageCommentsController.title = title
		return imageCommentsController
	}
}
