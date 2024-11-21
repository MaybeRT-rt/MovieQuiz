//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 07.11.2024.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    // MARK: - Displaying Data
    func show(quiz step: QuizStepViewModel)
    func showAlert(alertModel: AlertModel)
    
    // MARK: - UI Interaction
    func toggleAnswerButtons(_ isEnabled: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    // MARK: - UI State Updates
    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetImageBorder()
}
