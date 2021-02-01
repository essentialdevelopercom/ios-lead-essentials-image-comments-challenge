//
//  ViewController.swift
//  FeedCommentMVP
//
//  Created by Alok Subedi on 01/02/2021.
//

import UIKit

class ViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell")!
    }
}

