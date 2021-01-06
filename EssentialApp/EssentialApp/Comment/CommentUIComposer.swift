//
//  CommentUIComposer.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

public final class CommentUIComposer {
	private init() {}
	
	public static func commentComposeWith(loader: CommentLoader) -> CommentViewController {
		let presentationAdapter = CommentLoaderPresentationAdapter(commentLoader: MainQueueDispatchDecorator(decoratee: loader))
		 
		let bundle = Bundle(for: CommentViewController.self)
		let storyBoard = UIStoryboard(name: "Comment", bundle: bundle)
		let commentViewController = storyBoard.instantiateInitialViewController() as! CommentViewController
		commentViewController.delegate = presentationAdapter
		let presenter = CommentPresenter(
			loadingView: WeakRefVirtualProxy(commentViewController),
			errorView: WeakRefVirtualProxy(commentViewController),
			commentView: CommentViewAdapter(controller: commentViewController))
		presentationAdapter.presenter = presenter
		
		return commentViewController
	}
}

class MainQueueDispatchDecorator: CommentLoader {
	private let decoratee: CommentLoader
	init(decoratee: CommentLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderTask {
		decoratee.load { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async {
					completion(result)
				}
			}
		}
	}
}
