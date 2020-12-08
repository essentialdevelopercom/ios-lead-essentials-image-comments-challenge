//
//  WeakRefVirtualProxy+ImageComments.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed

extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
    func display(_ viewModel: ImageCommentsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ImageCommentsErrorView where T: ImageCommentsErrorView {
    func display(_ viewModel: ImageCommentsErrorViewModel) {
        object?.display(viewModel)
    }
}
