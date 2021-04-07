//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(commentsLoader: CommentsLoader) -> CommentsController {
		let presentationAdapter = CommentsLoaderPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: commentsLoader))
		let commentsController = makeCommentsController()
		commentsController.delegate = presentationAdapter
		let presenter = CommentsPresenter(
			errorView: WeakRefVirtualProxy(commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			commentsView: CommentsAdapter(controller: commentsController))
		presentationAdapter.presenter = presenter
		return commentsController
	}
	
	private static func makeCommentsController() -> CommentsController {
		let bundle = Bundle(for: CommentsController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
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
	private let loader: CommentsLoader
	var presenter: CommentsPresenter?
	
	init(loader: CommentsLoader) {
		self.loader = loader
	}
	
	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		loader.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(comments: comments)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
		}
	}
}
