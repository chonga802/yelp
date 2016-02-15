//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Christine Hong on 2/9/16.
//  Copyright © 2016 Christine Hong. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewcontroller: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, DealCellDelegate, DistanceDelegate, SortCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var filters : [String : AnyObject]!
    
    var dealOnly: Bool = false
    var distance: [String] = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    var sortBy: [String] = ["Best Match", "Distance", "Rating"]
    var categories: [[String:String]]!
    
    var switchStates : [Int : Bool]!
    var selectedCategories : [String]!
    var selectedDistance: String = "Auto"
    var selectedSortby: String = "Best Match"
    var distanceExpand: Bool = false
    var sortbyExpand: Bool = false
    
    override func viewDidLoad() {
        print("FILTERS VIEW CONTROLLER LOADING")
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        switchStates = [Int:Bool]()
        categories = yelpCategories()
        
        // Get previous filter settings
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("filters") != nil){
            filters = defaults.objectForKey("filters") as! [String: AnyObject]
            print(filters)
            dealOnly = filters["dealonly"] as! Bool
            selectedDistance = filters["distance"] as! String
            selectedSortby = filters["sortby"] as! String
            if filters["categories"] != nil {
                selectedCategories = filters["categories"] as! [String]
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Filter Buttons
    
    // action connected to Cancel button in Filters
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // action connected to Search button in Filters
    @IBAction func onSearchButton(sender: AnyObject) {
        print("Pressed search button")
        filters = [String:AnyObject]()

        filters["dealonly"] = dealOnly
        
        filters["distance"] = selectedDistance
        
        filters["sortby"] = selectedSortby
        
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        print("filters:")
        print(filters)
        
        // save filter settings
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(filters, forKey: "filters" )
        defaults.synchronize()
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("table titleForHeaderInSection")
        if section == 1 {
            return "Distance"
        } else if section == 2 {
            return "Sort By"
        } else if section == 3 {
            return "Category"
        }
        return ""
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        print("table numberOfSectionsInTableView")
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("table numberOfRowsInSection")
        var numRows : Int?
        if section == 0 {
            return 1
        } else if section == 1 {
            print("distanceExpand:")
            print(distanceExpand)
            if (distanceExpand) {
                return 1
            } else {
                numRows = distance.count
            }
        } else if section == 2 {
            print("sortbyExpand:")
            print(sortbyExpand)
            if (sortbyExpand) {
                return 1
            } else {
                numRows = sortBy.count
            }
        } else if section == 3 {
            numRows = categories.count
        }
        
        if (numRows != nil) {
            return numRows!
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("table cellForRowAtIndexPath")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DealCell", forIndexPath: indexPath) as! DealCell
            cell.delegate = self
            cell.dealSwitch.on = dealOnly
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DistanceCell", forIndexPath: indexPath) as! DistanceCell
            cell.delegate = self
            if (distanceExpand) {
                cell.distanceLabel!.text = selectedDistance
            } else {
                cell.distanceLabel!.text = distance[indexPath.row]
                // highlight selected distance
                if distance[indexPath.row] == selectedDistance {
                    cell.backgroundColor = UIColor.lightGrayColor();
                }
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SortCell", forIndexPath: indexPath) as! SortCell
            cell.delegate = self
            if (sortbyExpand){
                cell.sortLabel!.text = selectedSortby
            } else {
                cell.sortLabel!.text = sortBy[indexPath.row]
                // highlight selected sortby
                if sortBy[indexPath.row] == selectedSortby {
                    cell.backgroundColor = UIColor.lightGrayColor();
                }
            }
            return cell
        }
        // else statement
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        cell.delegate = self
        
        cell.switchLabel.text = categories[indexPath.row]["name"]
        
        // get selected categories from memory
        let code = categories[indexPath.row]["code"]!
        if selectedCategories != nil {
            if selectedCategories.contains(code) {
                switchStates[indexPath.row] = true
            }
        }
        
        //equivalent: cell.onSwitch.on = switchStates[indexPath.row] ?? false
        if switchStates[indexPath.row] != nil {
            cell.onSwitch.on = switchStates[indexPath.row]!
        } else {
            cell.onSwitch.on = false
        }
        
        return cell
    }
    
    func updateColor(indexPath: NSIndexPath) {
        var numRows = 0
        if indexPath.section == 1{
            numRows = distance.count
        } else if indexPath.section == 2 {
            numRows = sortBy.count
        }
        for row in 0 ... numRows - 1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: row, inSection: indexPath.section))
            if (indexPath.row == row) {
                cell!.backgroundColor = UIColor.lightGrayColor();
            }  else {
                cell!.backgroundColor = UIColor.whiteColor();
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("table didSelectRowAtIndexPath")
        tableView.beginUpdates()
        if indexPath.section == 1 {
            if (distanceExpand) {
                distanceExpand = false
                // show all rows
                tableView.reloadData()
                var distanceIndexPaths = [NSIndexPath]()
                for index in 0...distance.count {
                    distanceIndexPaths.append(NSIndexPath(forItem: index, inSection: 1))
                }
                tableView.reloadRowsAtIndexPaths(distanceIndexPaths, withRowAnimation: .Fade)
            } else {
                //distanceExpand = true
                selectedDistance = distance[indexPath.row]
                updateColor(indexPath)
                // hide rows
                //let deleteIndexPath = NSIndexPath(forItem: indexPath.row, inSection: indexPath.section)
                //tableView.reloadRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
        } else if indexPath.section == 2 {
            if (sortbyExpand) {
                sortbyExpand = false
                // show all rows
                var sortIndexPaths = [NSIndexPath]()
                for index in 0...sortBy.count {
                    sortIndexPaths.append(NSIndexPath(forItem: index, inSection: 2))
                }
                tableView.reloadRowsAtIndexPaths(sortIndexPaths, withRowAnimation: .Fade)
            } else {
                //sortbyExpand = true
                selectedSortby = sortBy[indexPath.row]
                updateColor(indexPath)
                // hide rows
                //let deleteIndexPath = NSIndexPath(forItem: indexPath.row, inSection: indexPath.section)
                //tableView.reloadRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
        }
        tableView.endUpdates()
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switchStates[indexPath.row] = value
        print("CATEGORIES: filters view controller got the switch event for Categories")
        print(switchStates)
    }
    
    func dealCell(dealCell: DealCell, didChangeValue value: Bool) {
        dealOnly = value
        print("DEAL: filters view controller got the switch event for Deal")
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
            ["name" : "African", "code": "african"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
            ["name" : "Arabian", "code": "arabian"],
            ["name" : "Argentine", "code": "argentine"],
            ["name" : "Armenian", "code": "armenian"],
            ["name" : "Asian Fusion", "code": "asianfusion"],
            ["name" : "Asturian", "code": "asturian"],
            ["name" : "Australian", "code": "australian"],
            ["name" : "Austrian", "code": "austrian"],
            ["name" : "Baguettes", "code": "baguettes"],
            ["name" : "Bangladeshi", "code": "bangladeshi"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Basque", "code": "basque"],
            ["name" : "Bavarian", "code": "bavarian"],
            ["name" : "Beer Garden", "code": "beergarden"],
            ["name" : "Beer Hall", "code": "beerhall"],
            ["name" : "Beisl", "code": "beisl"],
            ["name" : "Belgian", "code": "belgian"],
            ["name" : "Bistros", "code": "bistros"],
            ["name" : "Black Sea", "code": "blacksea"],
            ["name" : "Brasseries", "code": "brasseries"],
            ["name" : "Brazilian", "code": "brazilian"],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
            ["name" : "British", "code": "british"],
            ["name" : "Buffets", "code": "buffets"],
            ["name" : "Bulgarian", "code": "bulgarian"],
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Burmese", "code": "burmese"],
            ["name" : "Cafes", "code": "cafes"],
            ["name" : "Cafeteria", "code": "cafeteria"],
            ["name" : "Cajun/Creole", "code": "cajun"],
            ["name" : "Cambodian", "code": "cambodian"],
            ["name" : "Canadian", "code": "New)"],
            ["name" : "Canteen", "code": "canteen"],
            ["name" : "Caribbean", "code": "caribbean"],
            ["name" : "Catalan", "code": "catalan"],
            ["name" : "Chech", "code": "chech"],
            ["name" : "Cheesesteaks", "code": "cheesesteaks"],
            ["name" : "Chicken Shop", "code": "chickenshop"],
            ["name" : "Chicken Wings", "code": "chicken_wings"],
            ["name" : "Chilean", "code": "chilean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Corsican", "code": "corsican"],
            ["name" : "Creperies", "code": "creperies"],
            ["name" : "Cuban", "code": "cuban"],
            ["name" : "Curry Sausage", "code": "currysausage"],
            ["name" : "Cypriot", "code": "cypriot"],
            ["name" : "Czech", "code": "czech"],
            ["name" : "Czech/Slovakian", "code": "czechslovakian"],
            ["name" : "Danish", "code": "danish"],
            ["name" : "Delis", "code": "delis"],
            ["name" : "Diners", "code": "diners"],
            ["name" : "Dumplings", "code": "dumplings"],
            ["name" : "Eastern European", "code": "eastern_european"],
            ["name" : "Ethiopian", "code": "ethiopian"],
            ["name" : "Fast Food", "code": "hotdogs"],
            ["name" : "Filipino", "code": "filipino"],
            ["name" : "Fish & Chips", "code": "fishnchips"],
            ["name" : "Fondue", "code": "fondue"],
            ["name" : "Food Court", "code": "food_court"],
            ["name" : "Food Stands", "code": "foodstands"],
            ["name" : "French", "code": "french"],
            ["name" : "French Southwest", "code": "sud_ouest"],
            ["name" : "Galician", "code": "galician"],
            ["name" : "Gastropubs", "code": "gastropubs"],
            ["name" : "Georgian", "code": "georgian"],
            ["name" : "German", "code": "german"],
            ["name" : "Giblets", "code": "giblets"],
            ["name" : "Gluten-Free", "code": "gluten_free"],
            ["name" : "Greek", "code": "greek"],
            ["name" : "Halal", "code": "halal"],
            ["name" : "Hawaiian", "code": "hawaiian"],
            ["name" : "Heuriger", "code": "heuriger"],
            ["name" : "Himalayan/Nepalese", "code": "himalayan"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Hot Dogs", "code": "hotdog"],
            ["name" : "Hot Pot", "code": "hotpot"],
            ["name" : "Hungarian", "code": "hungarian"],
            ["name" : "Iberian", "code": "iberian"],
            ["name" : "Indian", "code": "indpak"],
            ["name" : "Indonesian", "code": "indonesian"],
            ["name" : "International", "code": "international"],
            ["name" : "Irish", "code": "irish"],
            ["name" : "Island Pub", "code": "island_pub"],
            ["name" : "Israeli", "code": "israeli"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "Jewish", "code": "jewish"],
            ["name" : "Kebab", "code": "kebab"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Kosher", "code": "kosher"],
            ["name" : "Kurdish", "code": "kurdish"],
            ["name" : "Laos", "code": "laos"],
            ["name" : "Laotian", "code": "laotian"],
            ["name" : "Latin American", "code": "latin"],
            ["name" : "Live/Raw Food", "code": "raw_food"],
            ["name" : "Lyonnais", "code": "lyonnais"],
            ["name" : "Malaysian", "code": "malaysian"],
            ["name" : "Meatballs", "code": "meatballs"],
            ["name" : "Mediterranean", "code": "mediterranean"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Middle Eastern", "code": "mideastern"],
            ["name" : "Milk Bars", "code": "milkbars"],
            ["name" : "Modern Australian", "code": "modern_australian"],
            ["name" : "Modern European", "code": "modern_european"],
            ["name" : "Mongolian", "code": "mongolian"],
            ["name" : "Moroccan", "code": "moroccan"],
            ["name" : "New Zealand", "code": "newzealand"],
            ["name" : "Night Food", "code": "nightfood"],
            ["name" : "Norcinerie", "code": "norcinerie"],
            ["name" : "Open Sandwiches", "code": "opensandwiches"],
            ["name" : "Oriental", "code": "oriental"],
            ["name" : "Pakistani", "code": "pakistani"],
            ["name" : "Parent Cafes", "code": "eltern_cafes"],
            ["name" : "Parma", "code": "parma"],
            ["name" : "Persian/Iranian", "code": "persian"],
            ["name" : "Peruvian", "code": "peruvian"],
            ["name" : "Pita", "code": "pita"],
            ["name" : "Pizza", "code": "pizza"],
            ["name" : "Polish", "code": "polish"],
            ["name" : "Portuguese", "code": "portuguese"],
            ["name" : "Potatoes", "code": "potatoes"],
            ["name" : "Poutineries", "code": "poutineries"],
            ["name" : "Pub Food", "code": "pubfood"],
            ["name" : "Rice", "code": "riceshop"],
            ["name" : "Romanian", "code": "romanian"],
            ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
            ["name" : "Rumanian", "code": "rumanian"],
            ["name" : "Russian", "code": "russian"],
            ["name" : "Salad", "code": "salad"],
            ["name" : "Sandwiches", "code": "sandwiches"],
            ["name" : "Scandinavian", "code": "scandinavian"],
            ["name" : "Scottish", "code": "scottish"],
            ["name" : "Seafood", "code": "seafood"],
            ["name" : "Serbo Croatian", "code": "serbocroatian"],
            ["name" : "Signature Cuisine", "code": "signature_cuisine"],
            ["name" : "Singaporean", "code": "singaporean"],
            ["name" : "Slovakian", "code": "slovakian"],
            ["name" : "Soul Food", "code": "soulfood"],
            ["name" : "Soup", "code": "soup"],
            ["name" : "Southern", "code": "southern"],
            ["name" : "Spanish", "code": "spanish"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"],
            ["name" : "Swabian", "code": "swabian"],
            ["name" : "Swedish", "code": "swedish"],
            ["name" : "Swiss Food", "code": "swissfood"],
            ["name" : "Tabernas", "code": "tabernas"],
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Tapas Bars", "code": "tapas"],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
            ["name" : "Tex-Mex", "code": "tex-mex"],
            ["name" : "Thai", "code": "thai"],
            ["name" : "Traditional Norwegian", "code": "norwegian"],
            ["name" : "Traditional Swedish", "code": "traditional_swedish"],
            ["name" : "Trattorie", "code": "trattorie"],
            ["name" : "Turkish", "code": "turkish"],
            ["name" : "Ukrainian", "code": "ukrainian"],
            ["name" : "Uzbek", "code": "uzbek"],
            ["name" : "Vegan", "code": "vegan"],
            ["name" : "Vegetarian", "code": "vegetarian"],
            ["name" : "Venison", "code": "venison"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "Wok", "code": "wok"],
            ["name" : "Wraps", "code": "wraps"],
            ["name" : "Yugoslav", "code": "yugoslav"]]
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
