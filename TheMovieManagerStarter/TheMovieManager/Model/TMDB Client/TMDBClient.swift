//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "1e8fed14b04d60aa2b510e5a046c0b3a"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getFavorites
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        case search(String)
        case addWatchlist
        case addFavorite
        case getPoster(String)
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" +
                Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" +
                Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken : return Endpoints.base +
                "/authentication/token/new"
                + Endpoints.apiKeyParam
            case .login : return Endpoints.base +
                    "/authentication/token/validate_with_login" +
                    Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base +
                "/authentication/session/new" + Endpoints.apiKeyParam
            case .webAuth: return "https://www.themoviedb.org/authenticate/"
                + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
            case .logout: return Endpoints.base + "/authentication/session"
                + Endpoints.apiKeyParam
            case .search(let query): return Endpoints.base +
                "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .addWatchlist: return Endpoints.base +
                "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .addFavorite: return Endpoints.base +
                "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam
                + "&session_id=\(Auth.sessionId)"
            case .getPoster(let posterPath): return "https://image.tmdb.org/t/p/w500/\(posterPath)"
            }
            
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            }else{
                completion([], error)
            }
        }
    }
    
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            }else{
                completion([], error)
            }
        }
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void){
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (response, error) in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func getSessionRequest(completion: @escaping (Bool, Error?) -> Void){
        
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { (response, error) in
            if let response = response{
                Auth.sessionId = response.sessionId
                completion(true, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func markWatchlistRequest(movieId: Int, isWatchlist: Bool, completion: @escaping (Bool, Error?) -> Void){
        let body = MarkWatchlist(mediaType: "movie", mediaId: movieId, watchlist: isWatchlist)
        taskForPOSTRequest(url: Endpoints.addWatchlist.url, responseType: TMDBResponse.self, body: body) { (response, error) in
            if let response = response{
                completion(response.statusCode == 1 || response.statusCode == 12 ||
                           response.statusCode == 13, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func markFavoriteRequest(movieId: Int, isFavorite: Bool, completion: @escaping (Bool, Error?) -> Void){
        let body = MarkFavorite(mediaType: "movie", mediaId: movieId, favorite: isFavorite)
        taskForPOSTRequest(url: Endpoints.addFavorite.url, responseType: TMDBResponse.self, body: body) { (response, error) in
            if let response = response{
                completion(response.statusCode == 1 || response.statusCode == 12 ||
                           response.statusCode == 13, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func getLoginRequest(_ username: String, _ password:String, completion: @escaping (Bool, Error?) -> Void){
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { (response, error) in
            if let response = response{
                Auth.requestToken = response.requestToken
                completion(true, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func getLogoutRequest(completion: @escaping (Bool, Error?) -> Void){
        let body = LogoutRequest(sessionId: Auth.sessionId)
        taskForDELETERequest(url: Endpoints.logout.url, responseType: LogoutResponse.self, body: body) { (response, error) in
            if let response = response{
                completion(response.success, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func searchMovies(query: String, completion: @escaping ([Movie], Error?) -> Void) -> URLSessionTask {
        let task = taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            }else{
                completion([], error)
            }
        }
        return task
    }
    
    class func downloadPosterImage(posterPath: String, completion: @escaping (Data?, Error?)-> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getPoster(posterPath).url) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                do{
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let data = try! JSONEncoder().encode(body)
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                do{
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    class func taskForDELETERequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let data = try! JSONEncoder().encode(body)
        var request =  URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                do{
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
        
    }
}
