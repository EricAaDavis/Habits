//
//  APIRequest.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

protocol APIRequest {
    //Response represents the type of object returned by a request
    associatedtype Response
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
    var filename: String { get }
}

//These values never change in our case so we set a default value
extension APIRequest {
    var host: String { "localhost" }
    var port: Int { 8080 }
}

//these values are usualy nil so we set a default value
extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

//Constructed api request
extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path // This could be: /users
        components.queryItems = queryItems
    
        var request = URLRequest(url: components.url!)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = "POST"
        
        return request
        
    }
}
//limiting the the use of the method inside to only those types whose associeted Response typed are Decodable
extension APIRequest where Response: Decodable {
    
    func sendFileRequest(completion: @escaping (Result<Response, Error>) -> Void) {
        
        let requestDelay: Double = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + requestDelay) {
            
            if let bundlePath = Bundle.main.path(forResource: filename, ofType: "json") {
                do {
                    let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                    let decoded = try JSONDecoder().decode(Response.self, from: jsonData ?? Data())
                    completion(.success(decoded))
                    print("Json success")
                } catch let error {
                    completion(.failure(error))
                    print("Local JSON not supported")
                    print(error.localizedDescription)
                }
            }
        }
        print("File Request - This is the URL: \(request) for \(filename)")

    }
    
    func sendApiRequest(completion: @escaping (Result<Response, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            do {
                if let data = data {
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded))
                } else if let error = error {
                    // check status code
                    // show login screen if appropriate
                    completion(.failure(error))
                }
            } catch {
                print("request failed")
            }
        }.resume()
        
        print("API Request - This is the URL: \(request) for \(filename)")

    }
}

enum ImageRequestError: Error {
    case couldNotInitializeFromData
}

extension APIRequest where Response == UIImage {
    func send(completion: @escaping (Result<Self.Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data,
               let image = UIImage(data: data) {
                completion(.success(image))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(ImageRequestError.couldNotInitializeFromData))
            }
        }.resume()
    }
}

extension APIRequest {
    func send(completion: @escaping (Error?) -> Void ) {
        print("This is the post request \(request)")
        URLSession.shared.dataTask(with: request) { _, _, error in
            completion(error)
        }.resume()
    }
}








