//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 05.11.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestions?
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    var currentQuestionIndex = 0
    var correctAnswersCount = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func resetCorrectAnswersCount() {
        correctAnswersCount = 0
    }
    
    // Конвертируем модель вопроса в модель отображения
    func convert(model: QuizQuestions) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: (UIImage(data: model.image ?? Data()) ?? UIImage()),
            questions: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")

        return question
    }
    
    func yesButtonTapped() {
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = true
        if correctAnswer == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
        viewController?.showResult(isCorrect: correctAnswer == currentQuestion.correctAnswer)
    }
    
     func noButtonTapped() {
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = false
        if correctAnswer == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
         viewController?.showResult(isCorrect: correctAnswer == currentQuestion.correctAnswer)
    }
}
