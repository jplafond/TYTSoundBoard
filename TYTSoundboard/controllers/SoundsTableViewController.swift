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

    var addButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonPressed(sender:)))

        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = self.addButtonItem

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
        return allSounds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.Table.identifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = Const.Table.noDataMsg

        if let allSounds = allSounds {
            cell.textLabel?.text = allSounds[indexPath.row].name
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
        // Return false if you do not want the item to be re-orderable.
        return true
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
        populateModel()

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

// MARK: - Table Specific Constants
extension Const {
    struct Table {
        static let identifier = "soundCell"

        static let noDataMsg = NSLocalizedString("No sound clips able to be downloaded",
                                                 comment: "Missing sound clips")
    }
}
