//
//  ImageCommentsViewAdapter.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

final class ImageCommentsViewAdapter: ImageCommentsView {
    private weak var controller: ImageCommentsViewController?
    
    init(controller: ImageCommentsViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { ImageCommentCellController(model: $0) })
    }

}
