//
//  GigController.swift
//  Gigs
//
//  Created by Stephanie Ballard on 8/5/20.
//  Copyright © 2020 Stephanie Ballard. All rights reserved.
//

import Foundation

class GigController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    enum NetworkError: Error {
        case failedSignUp
        case failedSignIn
        case noData
        case badData
        case noAuth
        case badAuth
        case otherError
        case noDecode
        case badImage
        case noEncode
        case noToken
    }
    
    // MARK: - Properties -
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private lazy var jsonDecoder = JSONDecoder()
    var gigs: [Gig] = []
    var bearer: Bearer?
    let baseURL: URL = URL(string:"https://lambdagigapi.herokuapp.com/api")!
    
    
    // MARK: - Network Calls -
    func signUp(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let signUpURL = baseURL.appendingPathComponent("users/signup")
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            print(String(data: jsonData, encoding: .utf8)!)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(.failure(.failedSignUp))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                print("Sign up failed with error: \(error)")
                completion(.failure(.failedSignUp))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Sign up was unsuccessful")
                completion(.failure(.failedSignUp))
                return
            }
            print("Sign up successful")
            completion(.success(true))
        }.resume()
    }
    
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let logInURL = baseURL.appendingPathComponent("users/login")
        var request = URLRequest(url: logInURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            print(String(data: jsonData, encoding: .utf8)!)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(.failure(.failedSignIn))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Sign in failed with error: \(error)")
                completion(.failure(.failedSignIn))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Sign in was unsuccessful")
                completion(.failure(.failedSignIn))
                return
            }
            
            guard let data = data else {
                print("Data was not received")
                completion(.failure(.noData))
                return
            }
            do {
                let token = try self.jsonDecoder.decode(Bearer.self, from: data)
                self.bearer = token
                print("Sign in function \(self.bearer?.token)")
                completion(.success(true))
            } catch {
                print("Error decoding bearer: \(error)")
                completion(.failure(.failedSignIn))
                return
            }
        }.resume()
    }
    
    func fetchGigs(with gig: Gig, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let fetchGigsURL = baseURL.appendingPathComponent("gigs")
        var request = URLRequest(url: fetchGigsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching gigs: \(error)")
                completion(.failure(.noData))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Error receiving response: \(response)")
                completion(.failure(.noToken))
                return
            }
            
            guard let data = data else {
                print("No data received from fetching gigs")
                completion(.failure(.noData))
                return
            }
            do {
                self.jsonDecoder.dateDecodingStrategy = .iso8601
                self.gigs = try self.jsonDecoder.decode([Gig].self, from: data)
                print(self.gigs.count)
                completion(.success(true))
            } catch {
                print("Error decoding gigs: \(error)")
                completion(.failure(.noData))
            }
        }.resume()
    }
    
    func createGig(with gig: Gig, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let createGigsURL = baseURL.appendingPathComponent("gigs")
        var request = URLRequest(url: createGigsURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try jsonEncoder.encode(gig)
            request.httpBody = jsonData
        } catch {
            print("Error encoding gig: \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error creating gig: \(error)")
                completion(.failure(.noEncode))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("\(response)")
                completion(.failure(.badAuth))
                return
            }
            completion(.success(true))
        }.resume()
    }
}





