//
//  ResultsViewController.swift
//  SmartCycle
//
//  Created by Tam Nguyen on 10/27/19.
//  Copyright © 2019 Rho Bros Co. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var results = [NSDictionary]()
    var text = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self 
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Result")
        
        let result = results[indexPath.row]
        let title = result["description"]
        let score = result["score"]
        
        let scoreString = String(describing: score!)
    
        
        let doubleScore = Double(scoreString)
        let doubleStr = String(format: "%.2f", doubleScore! * 100)
    
        cell.textLabel?.text = title! as! String
        cell.detailTextLabel?.text = doubleStr + "%"
        
        return cell
    }
}
