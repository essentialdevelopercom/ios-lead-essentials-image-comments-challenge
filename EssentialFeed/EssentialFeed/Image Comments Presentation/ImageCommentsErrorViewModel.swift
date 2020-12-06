//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

public struct ImageCommentsErrorViewModel {
    public let message: String?
    
    static var noError: ImageCommentsErrorViewModel {
        return ImageCommentsErrorViewModel(message: nil)
    }
}
