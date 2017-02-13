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

    @IBOutlet var searchBar: UISearchBar!
    let refreshControl = UIRefreshControl()
    
    @IBAction func NetChange(_ sender: Any) {
        loadData(refreshControl: refreshControl)
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var NetworkView: UIView!
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]?
    var endPoint: String!
    var offset: Int = 0
    var isMoreDataLoading = false
    
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
        loadData(refreshControl: refreshControl)
    }
    
    func loadData(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        if let endPoint = endPoint {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)&offset=\(offset*20)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                    self.filteredData = self.movies
                    self.tableView.reloadData()
                    self.isMoreDataLoading = false
                    refreshControl.endRefreshing()
                    self.NetworkView.isHidden = true
                }
            }
            else {
                self.NetworkView.isHidden = false
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        task.resume()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl as! URL)
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        return cell
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredData = self.movies
            
        } else {
            if let movies = movies as? [[String: Any]] {
                self.filteredData = []
                for movie in movies {
                    if let title = movie["title"] as? String {
                        if (title.range(of: searchText, options: .caseInsensitive) != nil) {
                            self.filteredData!.append(movie as NSDictionary)
                        }
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = backgroundView
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        detailViewController.hidesBottomBarWhenPushed = true
        
       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                offset += 1
                loadData(refreshControl: refreshControl)
            }
        }
    }

}
