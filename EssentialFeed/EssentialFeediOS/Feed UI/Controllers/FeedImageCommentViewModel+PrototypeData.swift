//
//  FeedImageCommentViewModel+PrototypeData.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension FeedImageCommentViewModel {
	static var prototypeComments: [FeedImageCommentViewModel] {
		return [
			FeedImageCommentViewModel(author: "Mary", date: "2 weeks ago", comment: "It was announced in August 2017 that major restoration work would take place at a cost of £1million, as the Pier has not received any major maintenance works for many years and is now in need of a refurbishment. The last restoration and renovation programme was in 1980s. The work will be funded by Bangor City Council and is likely to take up to three years to complete. Initially, the pier remained fully open to the public during the restoration works. However, following a structural report which found the pier head to be in a dangerous condition, it was closed to the public on a temporary basis in June 2018."),
			FeedImageCommentViewModel(author: "Tyler", date: "1 week ago", comment: "In 1971, the pier closed on safety grounds, with ownership being passed to Arfon Borough Council in 1974."),
			FeedImageCommentViewModel(author: "Marvin", date: "3 days ago", comment: "Opened to the public on 14 May 1896."),
		]
	}
}
