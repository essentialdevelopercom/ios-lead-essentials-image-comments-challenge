//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedCommentsLoaderPresentationAdapter: FeedCommentsViewControllerDelegate {
	private let feedCommentsLoader: FeedCommentsLoader
	var presenter: FeedCommentsPresenter?
	private var task: FeedCommentsLoaderTask?
	
	init(feedCommentsLoader: FeedCommentsLoader) {
		self.feedCommentsLoader = feedCommentsLoader
	}
	
	func didRequestFeedCommentsRefresh() {
		presenter?.didStartLoadingFeedComments()
		
		task = feedCommentsLoader.load {[weak self] result in
			switch result {
			case .success(let comments):
				self?.presenter?.didFinishLoadingFeedComments(with: comments)
			case .failure(let error):
				self?.presenter?.didFinishLoadingFeedComments(with: error)
			}
		}
	}
	
	deinit {
		task?.cancel()
	}
}
