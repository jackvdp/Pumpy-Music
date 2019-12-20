

import UIKit
import MediaPlayer

class MediaViewController: UITableViewController, MPMediaPickerControllerDelegate  {
    
    var mediaItem: MPMediaItem?
    var mediaLabel: String!
    var mediaID: String!
    let playlists = MPMediaQuery.playlists().collections
    let myMediaPlayer = MPMusicPlayerController.systemMusicPlayer
    var playlistTitle: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaylists()
    }

    override func viewWillDisappear(_ animated: Bool) {
        performSegue(withIdentifier: Id.soundUnwindIdentifier, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.textColor =  UIColor.gray
//        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 10)
//        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = .left
//    }
    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // Return the number of sections.
//        return 4
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistTitle.count
    }
    
    
    // override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return 40.0
    //}

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        cell.textLabel?.text = playlistTitle[indexPath.row]
        return cell
    
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            mediaLabel = cell?.textLabel?.text!
            cell?.setSelected(true, animated: true)
            cell?.setSelected(false, animated: true)
            let cells = tableView.visibleCells
            for c in cells {
                let section = tableView.indexPath(for: c)?.section
                if (section == indexPath.section && c != cell) {
                    c.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
            self.performSegue(withIdentifier: "soundUnwindSegue", sender: self)
        }
        
    }
    
        // MARK: - Functions

    func loadPlaylists() {
        if playlists != nil {
            for playlist in playlists! {
            playlistTitle.append(playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String)
            }
        }
         
     }

}


 
