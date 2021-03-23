//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let refreshController = ImageCommentsRefreshController(url: url, loader: loader)
		let viewController = ImageCommentsViewController(refreshController: refreshController)
		refreshController.onCommentsLoad = { [weak viewController] comments in
			viewController?.tableModel = comments.map {
				ImageCommentsCellController(model: $0, currentDate: currentDate)
			}
		}
		return viewController
	}
}
