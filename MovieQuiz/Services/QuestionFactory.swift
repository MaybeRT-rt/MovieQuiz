//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 07.10.2024.
//
import Foundation

class QuestionFactory {
    
    // Массив вопросов для викторины
    private let questions: [QuizQuestions] = [
        QuizQuestions(image: "The Godfather",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "The Dark Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Kill Bill",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "The Avengers",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Deadpool",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "The Green Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Old",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "The Ice Age Adventures of Buck Wild",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "Tesla",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "Vivarium",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
    ]
    
    func requestNextQuestion() -> QuizQuestions? {
        guard let index = (0...questions.count).randomElement() else {
            return nil
        }
        return questions[safe: index]
    }
    
}
