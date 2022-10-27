//
//  SearchViewController.swift
//  WA
//
//  Created by alekseienko on 27.10.2022.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filterCitiesList: [String] = citiesList
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterCitiesList = []
        if searchText == "" {
            filterCitiesList = citiesList
        } else {
            for city in citiesList {
                if city.lowercased().contains(searchText.lowercased()) {
                    filterCitiesList.append(city)
                }
            }
        }
        self.tableView.reloadData()
    }
}
// MARK: - SETUP TABLE VIEW
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCitiesList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = filterCitiesList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.defaults.set(filterCitiesList[indexPath.row], forKey:  "City")
        }
}
