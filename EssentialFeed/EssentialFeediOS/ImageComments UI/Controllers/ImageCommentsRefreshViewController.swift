//
//  ImageCommentsRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class ImageCommentsRefreshViewController: NSObject {
	private let imageCommentsLoader: ImageCommentsLoader
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()

	var onRefresh: (([ImageComment]) -> Void)?

	init(imageCommentsLoader: ImageCommentsLoader) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	@objc func refresh() {
		view.beginRefreshing()
		imageCommentsLoader.load { [weak self] result in
			if let imageComments = try? result.get() {
				self?.onRefresh?(imageComments)
			}
			self?.view .endRefreshing()
		}
	}
}
