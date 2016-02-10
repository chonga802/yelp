//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Christine Hong on 2/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewcontroller: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        var filters = [String : AnyObject]()
        
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories != nil {
            return categories!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
        
//        if switchStates[indexPath.row] != nil {
//            cell.onSwitch.on = switchStates[indexPath.row]!
//        } else {
//            cell.onSwitch.on = false
//        }
        
        // equivalent to above if statement
        // default state for switch set to off now
        cell.onSwitch.on = switchStates[indexPath.row] ?? false
        
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switchStates[indexPath.row] = value
        print("filters view controller got the switch event")
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghan"],
            ["name" : "African", "code" : "african"],
            ["name": "American, New", "code": "newamerican"],
        ["name" : "Bafghan", "code": "afghan"],
        ["name" : "Bafrican", "code" : "african"],
        ["name": "Bamerican, New", "code": "newamerican"],
        ["name" : "Cafghan", "code": "afghan"],
        ["name" : "Cafrican", "code" : "african"],
        ["name": "Camerican, New", "code": "newamerican"],
            ["name" : "Dafrican", "code" : "african"],
            ["name": "Damerican, New", "code": "newamerican"],
            ["name" : "Eafghan", "code": "afghan"],
            ["name" : "Eafrican", "code" : "african"]]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }
    */
    

}
