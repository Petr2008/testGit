//
//  TableViewController.swift
//  testGit
//
//  Created by Petr Gusakov on 06.08.2021.
//

import UIKit

class TableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var userNameField: UITextField!
    
//    var userName: String?
    var repoList = [Repo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func readFromServer(userName: String) {
        let name = "https://api.github.com/users/" + userName + "/repos"
        let searchURL = URL(string: name)!

        self.repoList = Array()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        URLSession.shared.dataTask(with: searchURL) { data, response, error in
//            print(response as Any)
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    self.createContext(data: data!)
                } else {
                    DispatchQueue.main.async {
                        self.userNameField.text = "Bad Request"
                    }
                }
            }
        }.resume()
    }
    
    func createContext(data: Data) {
        let context = String(decoding: data, as: UTF8.self)
        repoList = Array()
        
        let repoContextList = context.components(separatedBy: "},{")
        for repoContext in repoContextList {
            let components = repoContext.components(separatedBy: "},")
            // заголовок
            let header = components[0]
            let name = header.slice(from: "\"name\":\"", to: "\"")!
            // описание
            let body = components[1]
            let urlStr = body.slice(from: "html_url\":\"", to: "\"")!
            let description = body.slice(from: "description\":", to: ",")!
            let default_branch = repoContext.slice(from: "default_branch\":\"", to: "\"")!
                                                   //default_branch
            var language = repoContext.slice(from: "language\":\"", to: "\"")
            if language == nil {
                language = "n/a"
            }
                                            
            let repo = Repo(name: name, url: URL(string: urlStr)!, description: description, language: language!, default_branch: default_branch)
            repoList.append(repo)
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func goToUser(_ sender: Any) {
        if userNameField .text != "" {
            readFromServer(userName: userNameField.text!)
            
            userNameField.endEditing(true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("return pressed")
//        textField.resignFirstResponder()
        if textField.text != "" {
            readFromServer(userName: textField.text!)
            
            textField.endEditing(true)
            return false
        }
        return true
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return repoList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = repoList[indexPath.row].name
        cell.detailTextLabel?.text = repoList[indexPath.row].language

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

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Repo" {
            let repoViewController = segue.destination as! RepoViewController
            
            let index = tableView.indexPathForSelectedRow?.row
            repoViewController.repo = repoList[index!]
//            setupViewController.delegate = self
        }
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
}
