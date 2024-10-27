//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 07.10.2024.
//
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelegate?
    private let movieLoader: MoviesLoading
    
    private var movies: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate?, movieLoader: MoviesLoading) {
        self.delegate = delegate
        self.movieLoader = movieLoader
    }
    
    func loadData() {
        movieLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    print("Failed to load movies: \(error.localizedDescription)")
                    self.delegate?.didFailToLoadData(error: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self, !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            let index = Int.random(in: 0..<self.movies.count)
            let movie = self.movies[index]
            
            let networkClient = NetworkClient()
            networkClient.fetch(url: movie.resizedImageURL) { result in
                switch result {
                case .success(let imageData):
                    let rating = Float(movie.rating) ?? 0
                    let text = "Рейтинг этого фильма больше чем 7?"
                    let correctAnswer = rating > 7
                    let question = QuizQuestions(image: imageData, text: text, correctAnswer: correctAnswer)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didReceiveNextQuestion(question: question)
                    }
                    
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData(error: error)
                    }
                }
            }
        }
    }
}
    
// Массив вопросов для викторины
//    private let questions: [QuizQuestions] = [
//        QuizQuestions(image: "The Godfather",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "The Dark Knight",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "Kill Bill",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "The Avengers",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "Deadpool",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "The Green Knight",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: true),
//        QuizQuestions(image: "Old",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: false),
//        QuizQuestions(image: "The Ice Age Adventures of Buck Wild",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: false),
//        QuizQuestions(image: "Tesla",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: false),
//        QuizQuestions(image: "Vivarium",
//                      text: "Рейтинг этого фильма больше чем 6?",
//                      correctAnswer: false),
//    ]
//
