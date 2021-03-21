//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public class ImageCommentsViewController: UITableViewController {
	private var url: URL!
	private var loader: ImageCommentLoader?
	
	public convenience init(url: URL, loader: ImageCommentLoader) {
		self.init()
		self.url = url
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
		_ = loader?.load(from: url) { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

