//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
import XCTest

extension ImageCommentsUIIntegrationTests {
    func assertThat(
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

    func assertThat(
        _ sut: ImageCommentsViewController,
        hasViewConfiguredFor comment: (model: ImageComment, presentable: PresentableImageComment),
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.commentView(at: index)
        let model = comment.model
        let presentable = comment.presentable

        guard let cell = view else {
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
}
