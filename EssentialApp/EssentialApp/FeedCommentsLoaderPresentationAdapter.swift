//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedCommentsLoaderPresentationAdapter: FeedCommentsViewControllerDelegate {
	private let url: URL
	private let feedCommentsLoader: FeedCommentsLoader
	var presenter: FeedCommentsPresenter?
	
	init(url: URL, feedCommentsLoader: FeedCommentsLoader) {
		self.url = url
		self.feedCommentsLoader = feedCommentsLoader
	}
	
	func didRequestFeedCommentsRefresh() {
		presenter?.didStartLoadingFeedComments()
		
		feedCommentsLoader.load(url: url) {[weak self] result in
			switch result {
			case .success(let comments):
				self?.presenter?.didFinishLoadingFeedComments(with: comments)
			case .failure(let error):
				self?.presenter?.didFinishLoadingFeedComments(with: error)
			}
		}
	}
}
