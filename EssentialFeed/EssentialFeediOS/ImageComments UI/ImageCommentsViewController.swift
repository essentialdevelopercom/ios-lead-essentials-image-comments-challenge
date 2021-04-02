//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsViewController: UITableViewController {
	private var loader: ImageCommentsLoader?

	public convenience init(loader: ImageCommentsLoader) {
		self.init()
		self.loader = loader
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}

	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader?.load { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}
