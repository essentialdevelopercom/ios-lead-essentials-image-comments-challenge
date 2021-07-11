//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(commentsLoader: @escaping () -> CommentsLoader.Publisher) -> CommentsController {
		let presentationAdapter = CommentsLoaderPresentationAdapter(commentsLoader: commentsLoader)
		let commentsController = makeCommentsController()
		commentsController.delegate = presentationAdapter
		let presenter = CommentsPresenter(
			errorView: WeakRefVirtualProxy(commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			commentsView: CommentsAdapter(controller: commentsController))
		commentsController.title = presenter.title
		presentationAdapter.presenter = presenter
		return commentsController
	}
	
	private static func makeCommentsController() -> CommentsController {
		let bundle = Bundle(for: CommentsController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateViewController(identifier: "CommentsController") as! CommentsController
		return commentsController
	}
}

private final class CommentsAdapter: CommentView {
	private weak var controller: CommentsController?
	
	init(controller: CommentsController) {
		self.controller = controller
	}
	
	func display(_ viewModel: CommentListViewModel) {
		controller?.display(viewModel.comments.map {
			CommentCellController(model: $0)
		})
	}
}

private final class CommentsLoaderPresentationAdapter: CommentsControllerDelegate {
	private let commentsLoader: () -> CommentsLoader.Publisher
	private var cancellable: Cancellable?
	var presenter: CommentsPresenter?
	
	init(commentsLoader: @escaping () -> CommentsLoader.Publisher) {
		self.commentsLoader = commentsLoader
	}
	
	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		cancellable = commentsLoader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					break

				case let .failure(error):
					self?.presenter?.didFinishLoadingComments(with: error)
				}
			}, receiveValue: { [weak self] comments in
				self?.presenter?.didFinishLoadingComments(comments: comments)
			})
	}
}
