//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 12.07.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ResourceView {
	associatedtype ResourceViewModel
	func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
	public typealias Mapper = (Resource) -> View.ResourceViewModel
	
	private let resourceView: View
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	private let mapper: Mapper
	
	private var feedLoadError: String {
		return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
			 tableName: "Feed",
			 bundle: Bundle(for: LoadResourcePresenter.self),
			 comment: "Error message displayed when we can't load the image feed from the server")
	}
	
	public init(resourceView: View, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
		self.resourceView = resourceView
		self.loadingView = loadingView
		self.errorView = errorView
		self.mapper = mapper
	}
	
	public static var title: String {
		return NSLocalizedString("FEED_VIEW_TITLE",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Title for the feed view")
	}
	
	public func didStartLoading() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoading(with resource: Resource) {
		resourceView.display(mapper(resource))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeed(with error: Error) {
		errorView.display(.error(message: feedLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
