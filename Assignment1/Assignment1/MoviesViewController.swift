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
        
        self.navigationItem.title = "Movies"
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(red: 0.250, green: 0.25, blue: 1.0, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22),
                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(refreshControl: refreshControl)
    }
    
    func loadData(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        if let endPoint = endPoint {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")!
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
            //let imageUrl = NSURL(string: baseUrl + posterPath)
            let smallImageUrl = "https://image.tmdb.org/t/p/w45" + posterPath
            let largeImageUrl = "https://image.tmdb.org/t/p/original" + posterPath
            //cell.posterView.setImageWith(imageUrl as! URL)
            let smallImageRequest = NSURLRequest(url: NSURL(string: smallImageUrl)! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: largeImageUrl)! as URL)
            cell.posterView.setImageWith(smallImageRequest as URLRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                cell.posterView.alpha = 0.0
                cell.posterView.image = smallImage;
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                cell.posterView.alpha = 1.0
                    
                }, completion: { (sucess) -> Void in
                    
                    // The AFNetworking ImageView Category only allows one request to be sent at a time
                    // per ImageView. This code must be in the completion block.
                    cell.posterView.setImageWith(
                        largeImageRequest as URLRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            cell.posterView.image = largeImage;
                            
                    },
                        failure: { (request, response, error) -> Void in
                            // do something for the failure condition of the large image request
                            // possibly setting the ImageView's image to a default image
                    })
                })
            },
                                         failure: { (request, response, error) -> Void in
                                            // do something for the failure condition
                                            // possibly try to get the large image
            })
        }
        cell.contentView.alpha = 0
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         UIView.animate(withDuration: 0.8, animations: {
         cell.contentView.alpha = 1.0
         })
 
        
    }
}
