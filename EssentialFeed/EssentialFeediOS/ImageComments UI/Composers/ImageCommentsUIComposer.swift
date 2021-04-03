//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let imageCommentsViewModel = ImageCommentsViewModel(imageCommentsLoader: imageCommentsLoader)
		let refreshController = ImageCommentsRefreshViewController(viewModel: imageCommentsViewModel)
		let imageCommentsController = ImageCommentsViewController(refreshController: refreshController)
		imageCommentsViewModel.onImageCommentsLoad = adaptImageCommentToCellControllers(forwardingTo: imageCommentsController, loader: imageCommentsLoader)
		return imageCommentsController
	}

	private static func adaptImageCommentToCellControllers(forwardingTo controller: ImageCommentsViewController, loader: ImageCommentsLoader) -> ([ImageComment]) -> Void {
		{ [weak controller] imageComments in
			controller?.tableModel = imageComments.map { model in
				ImageCommentCellController(viewModel: ImageCommentViewModel(model: model))
			}
		}
	}
}
