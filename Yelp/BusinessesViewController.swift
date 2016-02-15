//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Christine Hong on 4/23/15.
//  Copyright (c) 2015 Christine Hong. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    
    lazy var searchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 0))
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        print("VIEW DID LOAD")
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        searchBar.placeholder = "Restaurants"
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        self.filteredBusinesses = self.businesses
        getRestaurants()
    }
    
    private func getRestaurants() {
        print("get restaurants")
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Business.searchWithTerm("Restaurants", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = self.businesses
            self.tableView.reloadData()

            MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses != nil {
            return filteredBusinesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    // This method updates filteredBusinesses based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("USING SEARCH BAR FILTER")
        // When there is no text, filteredBusinesses is the same as the original data
        if searchText.isEmpty {
            filteredBusinesses = businesses
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredBusinesses = businesses.filter({(dataItem: Business) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        getRestaurants()
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewcontroller: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        print("SEARCHING IN FILTERS VIEW CONTROLLER")
        let dealOnly = filters["dealonly"] as? Bool
        let distance = filters["distance"] as? String
        let sortBy = filters["sortby"] as? String
        let categories = filters["categories"] as? [String]
        
        var distanceChoice : Int?
        if (distance == "0.3 miles") {
            distanceChoice = 482
        } else if (distance == "1 mile") {
            distanceChoice = 1609
        } else if (distance == "5 miles") {
            distanceChoice = 8046
        } else if (distance == "20 miles") {
            distanceChoice = 32187
        }
        
        var sortChoice : YelpSortMode?
        if (sortBy == "Distance") {
            sortChoice = .Distance
        } else if sortBy == "Rating"{
            sortChoice = .HighestRated
        } else {
            sortChoice = .BestMatched
        }
        
        Business.searchWithTerm("Restaurants", distance: distanceChoice, sort: sortChoice, categories: categories, deals: dealOnly) { (businesses: [Business]!, error: NSError!) -> Void in
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
        }
    }
    
}
