//
//  DetailViewController.swift
//  Assignment1
//
//  Created by CS Student on 2/7/17.
//  Copyright © 2017 LionelEisenberg. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        titleLabel.text = title
        overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterImageView.setImageWith(imageUrl as! URL)
        }
        
        print(movie)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
