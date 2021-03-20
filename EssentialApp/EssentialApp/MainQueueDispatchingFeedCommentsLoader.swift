//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchingFeedCommentsLoader: FeedCommentsLoader {
	private let adaptee: FeedCommentsLoader
	
	init(adaptee: FeedCommentsLoader) {
		self.adaptee = adaptee
	}
	
	func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
		adaptee.load(url: url) { result in
			if Thread.isMainThread {
				completion(result)
			}else{
				DispatchQueue.main.async {
					completion(result)
				}
			}
		}
	}
}
