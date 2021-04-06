//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
	return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	return (models, local)
}

func uniqueImageFeedComment(formatter: RelativeDateTimeFormatter) -> (model: FeedImageComment, viewModel: FeedImageCommentViewModel) {
	let model = FeedImageComment(id: UUID(), message: "any", createdAt: Date(), author: .init(username: "any"))
	let date = formatter.localizedString(for: model.createdAt, relativeTo: Date())
	let viewModel = FeedImageCommentViewModel(message: model.message,
											  creationDate: date,
											  author: model.author.username)
	return (model, viewModel)
}

func uniqueImageFeedComments(formatter: RelativeDateTimeFormatter) -> [(model: FeedImageComment, viewModel: FeedImageCommentViewModel)] {
	return [uniqueImageFeedComment(formatter: formatter),
			uniqueImageFeedComment(formatter: formatter)]
}

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
	
	private func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
