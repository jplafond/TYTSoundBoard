//
//  SoundsTableViewController.swift
//  TYTSoundboard
//
//  Created by Jp LaFond on 8/8/17.
//  Copyright © 2017 Jp LaFond. All rights reserved.
//

import AVFoundation
import UIKit

class SoundsTableViewController: UITableViewController {

    var allSounds: [Sound]?
    var filteredSounds: [Sound]?

    let searchController = UISearchController(searchResultsController: nil)

    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        // Configure the auto-resizing table view cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

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
            tmpAttributedText.addAttributes([NSAttributedStringKey.foregroundColor: Const.Table.color.text],
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
                    tmpAttributedText.addAttributes([NSAttributedStringKey.foregroundColor: Const.Table.color.highlighted],
                                                    range: resultRange)
                    currentRange = resultRange
                } else {
                    isDone = true
                }
            } while !isDone

            return tmpAttributedText
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Const.Table.identifier,
                                                 for: indexPath)

        // Configure the cell...
        if let soundCell = cell as? SoundTableViewCell {
            soundCell.updateTitle(text: Const.Table.noDataMsg)

            if let allSounds = allSounds {
                if isSearching,
                    let filteredSounds = filteredSounds {
                    let highlightedText = createHighlight(input: filteredSounds[indexPath.row].soundTitle,
                                                          search: searchController.searchBar.text!)

                    soundCell.updateTitle(attributedText: highlightedText)
                } else {
                    let sound = allSounds[indexPath.row]
                    soundCell.updateTitle(sound: sound)
                }
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

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard let selectedSound =
            (isSearching ? filteredSounds?[indexPath.row] :
                allSounds?[indexPath.row]) else {
                    print("Nothing to select")
                    return
        }
        print(selectedSound)
        play(sound: selectedSound)
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

    func populateModel() {
        allSounds = Sound.allClips()?.sorted {$0.soundTitle.lowercased() < $1.soundTitle.lowercased() }
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

// MARK: - Sound Playing Functionality
extension SoundsTableViewController {
    func play(sound: Sound) {
        play(soundData: sound.soundData)
    }

    private func play(soundData data: Data) {
        do {
            // The player needs to exist after the method, so we use an instance variable in the class
            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error: <\(error)>")
        }
    }
}

// MARK: - Custom Sound Cell
class SoundTableViewCell: UITableViewCell {
    @IBOutlet weak var multilineTitle: UILabel!

    func updateTitle(sound: Sound) {
        updateTitle(text: sound.soundTitle)
    }

    func updateTitle(text: String, textColor: UIColor = Const.Table.color.text) {
        multilineTitle.text = text
        multilineTitle.textColor = textColor
    }

    func updateTitle(attributedText: NSAttributedString) {
        multilineTitle.attributedText = attributedText
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
