//
//  ViewController.swift
//  FeedCommentMVP
//
//  Created by Alok Subedi on 01/02/2021.
//

import UIKit

class ViewController: UITableViewController {
    private let comments = ImageCommentModel.testComments
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell",for: indexPath) as! ImageCommentCell
        let model = comments[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

private extension ImageCommentCell {
    func configure(with model: ImageCommentModel) {
        usernameLabel.text = model.username
        dateLabel.text = model.date
        commentLabel.text = model.comment
    }
}
