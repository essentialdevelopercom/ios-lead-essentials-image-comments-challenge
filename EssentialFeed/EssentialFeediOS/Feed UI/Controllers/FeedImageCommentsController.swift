//
//  FeedImageCommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

struct FeedImageCommentViewModel {
	let author: String
	let date: String
	let comment: String
}

class FeedImageCommentsController: UITableViewController {
	private let comments = FeedImageCommentViewModel.prototypeComments
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return comments.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
		let model = comments[indexPath.row]
		cell.configure(with: model)
		return cell
	}
}

extension FeedImageCommentCell {
	func configure(with model: FeedImageCommentViewModel) {
		authorLabel.text = model.author
		dateLabel.text = model.date
		commentLabel.text = model.comment
	}
}
