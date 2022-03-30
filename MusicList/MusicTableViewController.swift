//
//  MusicTableViewController.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//

import UIKit

class MusicTableViewController: UITableViewController {
    
    let service = ItunesQueryService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register UITableCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchDate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let model = service.tracks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(model.name)(\(model.artist))"
        content.secondaryText = model.collectionViewURL.absoluteString
        
        // setup image
        do {
            let data = try Data(contentsOf: model.artworkURL)
            let image = UIImage(data: data)
            content.image = image
            
        } catch {
            print("Cannot download image")
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MusicTableViewController {
    private func fetchDate() {
        service.tracksUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}
