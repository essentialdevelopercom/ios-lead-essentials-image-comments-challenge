//
//  CommentViewController.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class CommentViewController: UITableViewController {
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = CommentPresenter.title
	}
}
