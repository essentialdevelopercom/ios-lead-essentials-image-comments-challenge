//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsUIComposer {
    static func imageCommentsComposeWith(commentsLoader: ImageCommentsLoader, url: URL) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        commentsController.delegate = ImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
        return commentsController
    }
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
    let loader: ImageCommentsLoader
    let url: URL

    init(loader: ImageCommentsLoader, url: URL) {
        self.loader = loader
        self.url = url
    }

    func didRequestCommentsRefresh() {
        _ = loader.load(from: url) { _ in }
    }
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
    func test_loadCommentsAction_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "http://any-url.com")!,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> (ImageCommentsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = ImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url)
        return (controller, loader)
    }

    private class LoaderSpy: ImageCommentsLoader {
        var loadCommentsCallCount = 0

        private struct Task: ImageCommentsLoaderTask {
            func cancel() {}
        }

        func load(from _: URL, completion _: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            loadCommentsCallCount += 1
            return Task()
        }
    }
}

extension ImageCommentsViewController {
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }
}
