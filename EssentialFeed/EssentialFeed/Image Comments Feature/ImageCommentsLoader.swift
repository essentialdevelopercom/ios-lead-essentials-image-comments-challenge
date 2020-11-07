//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 07/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[ImageComment], Error>
    
    func loadComments(from url: URL, completion: @escaping (Result) -> Void)
}
