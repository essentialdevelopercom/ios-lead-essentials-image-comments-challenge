//
//  Created by Flavio Serrazes on 15.01.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {

    func assertThat(_ sut: FeedImageCommentsViewController, isRendering comments: [FeedImageCommentPresenterModel],
                    file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedCommentsViews() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentsViews()) instead.", file: file, line: line)
        }
        
        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: FeedImageCommentsViewController, hasViewConfiguredFor comment: FeedImageCommentPresenterModel, at index: Int,
                    file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.commentView(at: index)
        
        guard let cell = view as? FeedImageCommentCell else {
            return XCTFail("Expected \(FeedImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.usernameText, comment.username,
            "Expected username text to be \(comment.username), but got \(String(describing: cell.usernameText)) instead", file: file, line: line)
        
        XCTAssertEqual(cell.createdAtText, comment.creationTime,
            "Expected created at text to be \(comment.creationTime), but got \(String(describing: cell.createdAtText)) instead", file: file, line: line)
        
        XCTAssertEqual(cell.commentText, comment.comment,
            "Expected message text to be \(comment.comment), but got \(String(describing: cell.commentText)) instead", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
    
}