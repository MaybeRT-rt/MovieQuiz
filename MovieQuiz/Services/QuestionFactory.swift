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
    private let questionGenerator: QuestionGeneratorProtocol
    
    private var movies: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate?, movieLoader: MoviesLoading, questionGenerator: QuestionGeneratorProtocol) {
        self.delegate = delegate
        self.movieLoader = movieLoader
        self.questionGenerator = questionGenerator
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
                    guard let questionGanerate = self.questionGenerator.generateQuestion(for: movie) else {
                        DispatchQueue.main.async {
                            self.delegate?.didReceiveNextQuestion(question: nil)
                        }
                        return
                    }
                    //print(movie.rating)
                    let question = QuizQuestions(image: imageData, text: questionGanerate.text, correctAnswer: questionGanerate.correctAnswer)
                    
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
