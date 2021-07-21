//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
	private init() {}

	private typealias ImageCommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], ImageCommentsViewAdapter>

	public static func imageCommentsComposedWith(
		imageCommentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ListViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: imageCommentsLoader)

		let feedController = makeImageCommentsViewController(title: ImageCommentsPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource

		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: ImageCommentsViewAdapter(controller: feedController),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController),
			mapper: { comments in
				ImageCommentsPresenter.map(comments)
			})

		return feedController
	}

	private static func makeImageCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title
		return feedController
	}
}
