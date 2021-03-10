//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 08/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCell: UITableViewCell {
	
}

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsErrorView, ImageCommentsLoadingView {
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		
	}
	
	public var delegate: ImageCommentsViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	private func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}
}
