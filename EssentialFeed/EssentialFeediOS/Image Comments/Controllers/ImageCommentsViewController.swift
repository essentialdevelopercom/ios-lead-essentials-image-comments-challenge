//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView{
	
	public var loader: ImageCommentsLoader?
	public var presenter: ImageCommentsPresenter?
	public var errorView = UILabel()
	
	var loaderTask:ImageCommentsLoaderTask?
	
	private var imageComments = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		
		tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageComment")
		
		refresh()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		loaderTask?.cancel()
	}
	
	@objc private func refresh() {
		self.presenter?.didStartLoadingImageComments()
		
		loaderTask = loader?.load{ [weak self] result in
			self?.refreshControl?.endRefreshing()
			
			switch result{
			case .success(let comments):
				self?.presenter?.didFinishLoadingImageComments(with: comments)
			case .failure(let error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
				break
			}
		}
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		imageComments = viewModel.imageComments
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading{
			self.refreshControl?.beginRefreshing()
		}
		else{
			self.refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView.text = viewModel.message
	}
	
	// MARK: - Table View
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageComment", for: indexPath) as! ImageCommentCell
		cell.configure(imageComment: imageComments[indexPath.row])
		
		return cell
	}
}
