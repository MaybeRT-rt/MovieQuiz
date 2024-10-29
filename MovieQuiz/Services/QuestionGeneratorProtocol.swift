//
//  QuestionGeneratorProtocol.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 29.10.2024.
//

protocol QuestionGeneratorProtocol {
    func generateQuestion(for movie: MostPopularMovie) -> QuizQuestions?
}
