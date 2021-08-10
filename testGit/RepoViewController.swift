//
//  RepoViewController.swift
//  testGit
//
//  Created by Petr Gusakov on 08.08.2021.
//

import UIKit

class RepoViewController: UIViewController {

    @IBOutlet var urlButton: UIButton!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var downLoadButton: UIBarButtonItem!
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var repo: Repo?
    var zipPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if repo != nil {
            urlButton.setTitle(repo!.url.absoluteString, for: .normal)
            languageLabel.text = "language:" + " " + repo!.language
            zipPath = repo!.url.absoluteString + "/archive/refs/heads/" + repo!.default_branch + ".zip"

            if repo!.description != "null" {
                descriptionTextView.text = repo!.description
                descriptionTextView.isHidden = false
            }

            downLoadButton.isEnabled = true
            title = repo!.name
        }
    }
    
    @IBAction func callSafari(_ sender: Any) {
        if let url = repo?.url {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func dowmloadZip(_ sender: Any) {
        
        activityIndicatorView.startAnimating()
        
        let urlZip = URL(string: zipPath!)!
        let fileName = repo!.name + ".zip"
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            let alertController = UIAlertController(title:NSLocalizedString("file Exists", comment: ""), message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("overwrite", comment: ""), style: .destructive) { (action) in
                self.download(url: urlZip, fileName: fileName)
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                self.activityIndicatorView.stopAnimating()
            }
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            self.download(url: urlZip, fileName: fileName)
//            do {
//                    try urlZip.download(to: .documentDirectory, using: fileName, overwrite: true) { url, error in
//                }
//            } catch {
//                print(error)
//            }
        }
    }
    
    func download(url: URL, fileName: String)  {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documentDirectory.appendingPathComponent(fileName)
        
        URLSession.shared.downloadTask(with: url) { location, _, error in
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: location!, to: destination)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }

        }.resume()

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension URL {
//    func download(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, Error?) -> Void) throws {
//        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let destination: URL
//        if let fileName = fileName {
//            destination = directory
//                .appendingPathComponent(fileName)
//                .appendingPathExtension(self.pathExtension)
//        } else {
//            destination = directory
//            .appendingPathComponent(lastPathComponent)
//        }
//        if !overwrite, FileManager.default.fileExists(atPath: destination.path) {
//            completion(destination, nil)
//            return
//        }
//        URLSession.shared.downloadTask(with: self) { location, _, error in
//            guard let location = location else {
//                completion(nil, error)
//                return
//            }
//            do {
//                if overwrite, FileManager.default.fileExists(atPath: destination.path) {
//                    try FileManager.default.removeItem(at: destination)
//                }
//                try FileManager.default.moveItem(at: location, to: destination)
//                completion(destination, nil)
//            } catch {
//                print(error)
//            }
//        }.resume()
//    }
//}
