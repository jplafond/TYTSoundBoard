//
//  SoundsTableViewController.swift
//  TYTSoundboard
//
//  Created by Jp LaFond on 8/8/17.
//  Copyright © 2017 Jp LaFond. All rights reserved.
//

import UIKit

class SoundsTableViewController: UITableViewController {

    var allSounds: [Sound]?
    var filteredSounds: [Sound]?

    var addButtonItem: UIBarButtonItem!

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonPressed(sender:)))

        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = self.addButtonItem

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        populateModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let allSounds = allSounds else {
            // 1 for the error string
            return 1
        }
        if isSearching,
            let filteredSounds = filteredSounds {
            return filteredSounds.count
        }
        return allSounds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Internal helper func to update the text
        func createHighlight(input string: String,
                             search: String) -> NSAttributedString {
            let nsstring = NSString(string: string)
            let tmpAttributedText = NSMutableAttributedString(string: string)
            tmpAttributedText.addAttributes([NSForegroundColorAttributeName: Const.Table.color.text],
                                            range: NSRange(location: 0,
                                                           length: string.characters.count))
            var currentRange: NSRange?
            var isDone = false
            repeat {
                let nextRangeToSearch: NSRange

                // Define the range to search
                if let currentRange = currentRange {
                    let updatedLocation = currentRange.location + 1
                    nextRangeToSearch = NSRange(location: updatedLocation,
                                                length: nsstring.length - updatedLocation)
                } else {
                    nextRangeToSearch = NSRange(location: 0,
                                                length: nsstring.length)
                }

                let resultRange = nsstring.range(of: search,
                                                 options: .caseInsensitive,
                                                 range: nextRangeToSearch,
                                                 locale: nil)
                if resultRange.location != NSNotFound {
                    tmpAttributedText.addAttributes([NSForegroundColorAttributeName: Const.Table.color.highlighted],
                                                    range: resultRange)
                    currentRange = resultRange
                } else {
                    isDone = true
                }
            } while !isDone

            return tmpAttributedText
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Const.Table.identifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = Const.Table.noDataMsg

        if let allSounds = allSounds {
            if isSearching,
                let filteredSounds = filteredSounds {
                let highlightedText = createHighlight(input: filteredSounds[indexPath.row].name,
                                                      search: searchController.searchBar.text!)
                cell.textLabel?.text = nil
                cell.textLabel?.attributedText = highlightedText
            } else {
                cell.textLabel?.attributedText = nil
                cell.textLabel?.text = allSounds[indexPath.row].name
                cell.textLabel?.textColor = Const.Table.color.text
            }
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // We don't want to do any editing, while we're searching
        return !isSearching
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            allSounds?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath],
                                 with: .fade)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

        guard var allSounds = allSounds else {
            return
        }

        let sound = allSounds.remove(at: fromIndexPath.row)
        allSounds.insert(sound, at: to.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // We don't want to do any editing, while we're searching
        return !isSearching
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table IBActions
extension SoundsTableViewController {
    @IBAction func refreshTriggered(sender: UIRefreshControl) {
        if !isSearching {
            populateModel()
        }

        sender.endRefreshing()
    }

    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        let sound = Sound(name: "*New* Animals R Innocent")
        let indexPath = IndexPath(row: 0, section: 0)
        allSounds?.insert(sound, at: indexPath.row)
        tableView.insertRows(at: [indexPath],
                             with: .automatic)
    }

    func populateModel() {
        allSounds = Sound.allClips()
        tableView.reloadData()
    }
}

// MARK: - Table Search Functionality
extension SoundsTableViewController: UISearchResultsUpdating {
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSounds = allSounds?.filter {
            sound in

            sound.shouldFilter(by: searchText)
        }

        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    var isSearching: Bool {
        return searchController.isActive &&
            searchController.searchBar.text != ""
    }
}

// MARK: - Table Specific Constants
extension Const {
    struct Table {
        static let identifier = "soundCell"

        static let noDataMsg = NSLocalizedString("No sound clips able to be downloaded",
                                                 comment: "Missing sound clips")

        struct color {
            static let text = UIColor.black.withAlphaComponent(0.8)
            static let highlighted = UIColor.red
        }
    }
}
