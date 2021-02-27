//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        imageView.image = UIImage(named: "PosterPlaceholder")
        if let poster = movie.posterPath{
            TMDBClient.downloadPosterImage(posterPath: poster) { (imageData, error) in
                guard let imageData = imageData else {
                    return
                }
                let image = UIImage(data: imageData)
                self.imageView.image = image
            }
        }
        
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        print("isWatchList: \(isWatchlist)")
        TMDBClient.markWatchlistRequest(movieId: movie.id, isWatchlist: !isWatchlist) { (isSuccess, error) in
            if isSuccess{
                if self.isWatchlist {
                    MovieModel.watchlist = MovieModel.watchlist.filter(){
                        $0 != self.movie
                    }
                }else{
                    MovieModel.watchlist.append(self.movie)
                }
                self.toggleBarButton(self.watchlistBarButtonItem, enabled: self.isWatchlist)
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markFavoriteRequest(movieId: movie.id, isFavorite: !isFavorite) { (isSuccess, error) in
            if isSuccess{
                if self.isFavorite {
                    MovieModel.favorites = MovieModel.favorites.filter(){
                        $0 != self.movie
                    }
                }else{
                    MovieModel.favorites.append(self.movie)
                }
                self.toggleBarButton(self.favoriteBarButtonItem, enabled: self.isFavorite)
            }
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
}
