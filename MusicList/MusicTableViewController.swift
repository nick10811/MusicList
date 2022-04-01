//
//  MusicTableViewController.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//

import UIKit

class MusicTableViewController: UITableViewController {
    
    private let service = ItunesQueryService.shared
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.searchBar.placeholder = "Song, Artist, ..."
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Music List"
        navigationItem.searchController = searchController
        // register UITableCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchData()
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

        let track = service.tracks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(track.name)"
        content.secondaryText = track.artist
        
        // setup image
        content.image = UIImage(systemName: "photo")
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: track.artworkURL) else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                content.image = image
                cell.contentConfiguration = content
            }
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = service.tracks[indexPath.row]
        let vc = DetailViewController(track: track)
        self.navigationController?.pushViewController(vc, animated: true)
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
    
}

extension MusicTableViewController {
    private func fetchData() {
        showIndicatorView()
        service.tracksUpdate = { [weak self] in
            self?.hideIndicatorView()
            self?.tableView.reloadData()
        }
    }
    
}

// MARK: - UISearchControllerDelegate, UISearchResultsUpdating
extension MusicTableViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchedText = searchController.searchBar.text {
            showIndicatorView()
            service.searchText = searchedText.isEmpty ? "Coldplay" : searchedText
        }
    }
    
}
