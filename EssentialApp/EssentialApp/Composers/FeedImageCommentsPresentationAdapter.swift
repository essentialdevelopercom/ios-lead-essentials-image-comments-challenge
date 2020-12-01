//
//  FeedImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentsPresentationAdapter: FeedImageCommentsViewControllerDelegate {
	
	var presenter: FeedImageCommentsPresenter?
	private let loader: FeedImageCommentsLoader
	let url: URL
	private var task: FeedImageCommentsLoaderTask?
	
	init(loader: FeedImageCommentsLoader, url: URL) {
		self.loader = loader
		self.url = url
	}
	
	public func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		task = loader.load(from: url) { [weak self] result
			in
			
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
			
		}
	}
	
	public func didCancelCommentsRequest() {
		task?.cancel()
	}
}
