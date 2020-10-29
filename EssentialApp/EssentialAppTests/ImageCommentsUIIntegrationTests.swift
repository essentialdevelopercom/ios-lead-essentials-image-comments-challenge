//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialApp
import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsUIIntegrationTests: XCTestCase {
    func test_commenstView_hasLocalizedTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

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

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

        loader.completeCommentsLoading(with: anyNSError())
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expected no loading indicator once user initiated loading completes with error"
        )
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let fixedDate = makeFixedDate()
        let (sut, loader) = makeSUT(date: fixedDate)
        let comments = makeUniqueComments()
        let models = comments.map { $0.model }

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: models)

        assertThat(sut, isRendering: comments)
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let fixedDate = makeFixedDate()
        let comments = makeUniqueComments()
        let models = comments.map { $0.model }
        let (sut, loader) = makeSUT(date: fixedDate)

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: models)
        assertThat(sut, isRendering: comments)

        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: [])
        assertThat(sut, isRendering: [])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let fixedDate = makeFixedDate()
        let (sut, loader) = makeSUT(date: fixedDate)
        let comments = makeUniqueComments()
        let models = comments.map { $0.model }

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: models, at: 0)

        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: anyNSError())

        assertThat(sut, isRendering: comments)
    }

    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCommentsLoading(with: anyNSError())
        XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_cancelsCommentsLoading_whenViewIsNotVisible() {
        let url = URL(string: "https://any-image-url.com")!
        let (sut, loader) = makeSUT(url: url)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.cancelledRequests, [], "Expected to has not cancelled requests")
        
        loader.completeCommentsLoading()
        XCTAssertEqual(loader.cancelledRequests, [], "Expected to has not cancelled requests after loading")
        
        sut.simulateUserInitiatedCommentsReload()
        sut.viewWillDisappear(false)
        XCTAssertEqual(loader.cancelledRequests, [url], "Expected to has cancelled requests")
    }

    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let exp = expectation(description: "Wait to load from background")

        sut.loadViewIfNeeded()

        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "http://any-url.com")!,
        date: Date = Date(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (ImageCommentsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = ImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url, date: date)
        trackForMemoryLeaks(controller, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (controller, loader)
    }

    private func makeComment(
        message: String,
        createdAt: (date: Date, representaton: String),
        username: String
    ) -> (model: ImageComment, presentable: PresentableImageComment) {
        let model = ImageComment(id: UUID(), message: message, createdAt: createdAt.date, author: username)
        let comment = PresentableImageComment(username: username, createdAt: createdAt.representaton, message: message)
        return (model, comment)
    }

    private func makeUniqueComments() -> [(model: ImageComment, presentable: PresentableImageComment)] {
        let comment0 = makeComment(
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1603411200), "1 day ago"),
            username: "a username"
        ) // 23 OCT 2020 - 00:00:00
        let comment1 = makeComment(
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1603494000), "1 hour ago"),
            username: "another username"
        ) // 23 OCT 2020 - 23:00:00

        return [comment0, comment1]
    }

    private func assertThat(
        _ sut: ImageCommentsViewController,
        isRendering comments: [(model: ImageComment, presentable: PresentableImageComment)],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedComments() == comments.count else {
            return XCTFail(
                "Expected \(comments.count) comments, but got \(sut.numberOfRenderedComments()) instead.",
                file: file,
                line: line
            )
        }

        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index)
        }
    }

    private func makeFixedDate() -> Date {
        Date(timeIntervalSince1970: 1603497600) // 24 OCT 2020 - 00:00:00
    }

    private func assertThat(
        _ sut: ImageCommentsViewController,
        hasViewConfiguredFor comment: (model: ImageComment, presentable: PresentableImageComment),
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.commentView(at: index)
        let model = comment.model
        let presentable = comment.presentable

        guard let cell = view as? ImageCommentCell else {
            return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(
            cell.usernameText,
            model.author,
            "Expected username text to be \(model.author), but got \(String(describing: cell.usernameText)) instead"
        )
        XCTAssertEqual(
            cell.commentText,
            model.message,
            "Expected message text to be \(model.author), but got \(String(describing: cell.commentText)) instead"
        )
        XCTAssertEqual(
            cell.createdAtText,
            presentable.createdAt,
            "Expected created at text to be \(presentable.createdAt), but got \(String(describing: cell.createdAtText)) instead"
        )
    }

    private class LoaderSpy: ImageCommentsLoader {
        var loadCommentsCallCount: Int { completions.count }
        var completions = [(ImageCommentsLoader.Result) -> Void]()
        private(set) var cancelledRequests = [URL]()

        private struct Task: ImageCommentsLoaderTask {
            let cancelCallback: () -> Void

            func cancel() {
                cancelCallback()
            }
        }

        func load(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return Task { [weak self] in
                self?.cancelledRequests.append(url)
            }
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            completions[index](.success(comments))
        }

        func completeCommentsLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

extension ImageCommentsViewController {
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    func numberOfRenderedComments() -> Int {
        tableView.numberOfRows(inSection: commentsSection)
    }

    func commentView(at row: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: row, section: commentsSection)
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }

    var commentsSection: Int { 0 }

    var errorMessage: String? {
        errorView?.message
    }
}

extension ImageCommentCell {
    var commentText: String? {
        commentLabel?.text
    }

    var usernameText: String? {
        usernameLabel?.text
    }

    var createdAtText: String? {
        createdAtLabel?.text
    }
}
