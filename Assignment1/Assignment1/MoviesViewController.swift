//
//  MoviesViewController.swift
//  Assignment1
//
//  Created by CS Student on 2/3/17.
//  Copyright © 2017 LionelEisenberg. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController:UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var searched = false
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navItem: UINavigationItem!
    let refreshControl = UIRefreshControl()
    
    @IBAction func NetChange(_ sender: Any) {
        loadData(refreshControl: refreshControl)
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var NetworkView: UIView!
    var movies: [NSDictionary]?
    var movieData: [String] = []
    var filteredData: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        NetworkView.isHidden = true
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        loadData(refreshControl: refreshControl)
    }
    
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        searched = false
        loadData(refreshControl: refreshControl)
    }
    
    func loadData(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                    for i in 0 ..< (self.movies?.count)! {
                        let movie = self.movies![i]
                        let movieTitle = movie["title"] as! String
                        self.movieData.append(movieTitle)
                    }
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
                    self.NetworkView.isHidden = true
                }
            }
            else {
                self.NetworkView.isHidden = false
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        filteredData = movieData
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searched) {
            print("\nSearched\n\\n\n\n")
            if let filteredData = filteredData {
                return filteredData.count
            }
            else {
                print("returned 0 for num of cells")
                return 0
            }
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (searched) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = filteredData?[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.posterView.setImageWith(imageUrl as! URL)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        return cell
    }
    
    
    
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText: String) {
        searched = true
        filteredData = searchText.isEmpty ? movieData : movieData.filter({(dataString: String) -> Bool in
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
    tableView.reloadData()
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
