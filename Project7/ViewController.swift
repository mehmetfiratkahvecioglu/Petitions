//
//  ViewController.swift
//  Project7
//
//  Created by Fırat Kahvecioğlu on 26.07.2022.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet var tableView: UITableView!
    
    var petitions = [Petition]()
    
    var petitionsFiltered = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Most Recent Petitions"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showAlert))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterData))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
            navigationItem.title = "Most Recent Petitions"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            navigationItem.title = "Top Rated Petitions"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

           
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            } else {
                showError()
            }
        } else {
            showError()
        }
        
                
        
    }
    
    @objc func filterData() {
            let ac = UIAlertController(title: "Filter with...", message: nil, preferredStyle: .alert)
            ac.addTextField()
            let submitAction = UIAlertAction(title: "Submit", style: .default) {
                [weak self, weak ac] _ in
                guard let filteredBy = ac?.textFields?[0].text else { return }
                self?.submit(filteredBy)
            }
            ac.addAction(submitAction)
            present(ac, animated: true)
        }
    
    
    func submit(_ filteredBy: String) {
            petitionsFiltered.removeAll()
            for petition in petitions {
                let titleLower = petition.title.lowercased()
                let bodyLower = petition.body.lowercased()
                if titleLower.contains(filteredBy) || bodyLower.contains(filteredBy) {
                    let title = petition.title
                    let body = petition.body
                    let group = [title, body]
                    petitionsFiltered.append(group)
                }
            }
            tableView.reloadData()
        }
    
    @objc func showAlert() {
        
        let alert = UIAlertController(title: "Resource", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        print("json: ",json)
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            print(jsonPetitions)
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if petitionsFiltered.isEmpty {
                    return petitions.count
                } else {
                    return petitionsFiltered.count
                }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
               if petitionsFiltered.isEmpty {
                   let petition = petitions[indexPath.row]
                   cell.textLabel?.text = petition.title
                   cell.detailTextLabel?.text = petition.body
               } else {
                   let petition = petitionsFiltered[indexPath.row]
                   cell.textLabel?.text = petition[0]
                   cell.detailTextLabel?.text = petition[1]
               }
               return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }


}

