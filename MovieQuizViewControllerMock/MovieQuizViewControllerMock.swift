//
//  MovieQuizViewControllerMock.swift
//  MovieQuizViewControllerMock
//
//  Created by Liz-Mary on 07.11.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    // MARK: - Displaying Data
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func showAlert(alertModel: AlertModel) {}
    
    // MARK: - UI Interaction
    func enabledNextButton(_ isEnabled: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    
    // MARK: - UI State Updates
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func resetImageBorder() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock) // передаем mock

        let emptyData = Data()
        let question = QuizQuestions(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.questions, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
} 
