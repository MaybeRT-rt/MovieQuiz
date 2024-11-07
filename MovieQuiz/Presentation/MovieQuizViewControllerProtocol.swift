//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 07.11.2024.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showFinalResult(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func enabledNextButton(_ isEnabled: Bool)
    func resetImageBorder()
    
    func showNetworkError(message: String)
}
