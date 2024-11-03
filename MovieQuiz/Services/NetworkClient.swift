//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 26.10.2024.
//

import Foundation

protocol NetworkRoutingProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRoutingProtocol {
    
    private enum NetworkError: Error {
        case codeError
        case noData
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {
                handler(.failure(NetworkError.noData))
                return
            }
            handler(.success(data))
        }
        task.resume()
    }
}
