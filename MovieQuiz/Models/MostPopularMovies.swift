//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 26.10.2024.
//
import Foundation

struct MostPopularMovies: Codable {
    let items: [MostPopularMovie]
    let errorMessage: String
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
        // Генерируем URL для уменьшенного изображения
        let baseURLString = imageURL.absoluteString.components(separatedBy: "._")[0]
        let resizedURLString = baseURLString + "._V0_UX600_.jpg"
        return URL(string: resizedURLString) ?? imageURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
