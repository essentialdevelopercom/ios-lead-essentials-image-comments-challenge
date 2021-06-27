
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() {}

	private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsAdapter>

	public static func commentsComposedWith(
		loader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
		let presentationAdapter = CommentsPresentationAdapter(loader: loader)

		let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title)
		commentsController.onRefresh = presentationAdapter.loadResource

		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: CommentsAdapter(
				controller: commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			errorView: WeakRefVirtualProxy(commentsController),
			mapper: { comments in
				ImageCommentsPresenter.map(comments)
			})

		return commentsController
	}

	private static func makeCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! ListViewController
		commentsController.title = title
		return commentsController
	}
}

private final class CommentsAdapter: ResourceView {
	private weak var controller: ListViewController?

	init(controller: ListViewController) {
		self.controller = controller
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map({ comment in

			let imageCellController = ImageCommentCellController(viewModel: comment)

			let cellController = CellController(id: comment, imageCellController)

			return cellController
		}))
	}
}
