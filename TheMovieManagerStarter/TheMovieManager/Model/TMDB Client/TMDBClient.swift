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
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" +
                Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken : return Endpoints.base +
                "/authentication/token/new"
                + Endpoints.apiKeyParam
            case .login :
                return Endpoints.base +
                    "/authentication/token/validate_with_login" +
                    Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base +
                "/authentication/session/new" + Endpoints.apiKeyParam
            case .webAuth: return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
            case .logout: return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            }
            
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url){
            data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let reponseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = reponseObject.requestToken
                completion(true, nil)
            }catch{
                completion(false, error)
            }
            
        }
        task.resume()
    }
    
    class func getSessionRequest(completion: @escaping (Bool, Error?) -> Void){
        let request = TMDBClient.getSessionURLRequest()
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let reponseObject = try decoder.decode(SessionResponse.self, from: data)
                Auth.sessionId = reponseObject.sessionId
                completion(true, nil)
            }catch{
                completion(false, error)
            }
            
        }
        task.resume()
    }
    
    class func getLoginRequest(_ username: String, _ password:String, completion: @escaping (Bool, Error?) -> Void){
        let request = TMDBClient.getLoginURLRequest(username, password)
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            do{
                let reponseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = reponseObject.requestToken
                completion(true, nil)
            }catch{
                completion(false, error)
            }
            
        }
        task.resume()
    }
    
    class func getLogoutRequest(completion: @escaping (Bool, Error?) -> Void){
        let request = TMDBClient.getLogoutURLRequest()
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            do{
                let reponseObject = try decoder.decode(LogoutResponse.self, from: data)
                completion(reponseObject.success, nil)
            }catch{
                completion(false, error)
            }
            
        }
        task.resume()
    }
    private class func getLoginURLRequest(_ username: String, _ password: String) -> URLRequest{
        
        let encoder = JSONEncoder()

        let data = try! encoder.encode(LoginRequest(username: username, password: password, requestToken: Auth.requestToken))
        var request =  URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
    
    private class func getSessionURLRequest() -> URLRequest{
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(PostSession(requestToken: Auth.requestToken))
        var request =  URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
    
    private class func getLogoutURLRequest() -> URLRequest{
        
        let encoder = JSONEncoder()

        let data = try! encoder.encode(LogoutRequest(sessionId: Auth.sessionId))
        var request =  URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
}
