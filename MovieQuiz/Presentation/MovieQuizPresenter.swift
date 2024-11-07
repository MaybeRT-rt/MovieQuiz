//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 05.11.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    let questionsAmount: Int = 10
    var currentQuestionIndex = 0
    var correctAnswersCount = 0
    
    var currentQuestion: QuizQuestions?
    
    weak var viewController: MovieQuizViewController?
    var alertDelegate: AlertPresenterDelegate?
    private var statisticService: StatisticServiceProtocol?
    var questionFactory: QuestionFactoryProtocol?
    
    // Инициализация презентера, создаем зависимости внутри
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        // Инициализация зависимостей
        self.questionFactory = QuestionFactory(delegate: self, movieLoader: MoviesLoader(), questionGenerator: QuestionGenerator())
        self.statisticService = StatisticService()
        viewController.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //    func resetCorrectAnswersCount() {
    //        correctAnswersCount = 0
    //    }
    
    // Конвертируем модель вопроса в модель отображения
    func convert(model: QuizQuestions) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: (UIImage(data: model.image ?? Data()) ?? UIImage()),
            questions: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return question
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        viewController?.enabledNextButton(isEnabled)
    }
    
    func yesButtonTapped() {
        proceedWithAnswer(isYes: true)
    }
    
    func noButtonTapped() {
        proceedWithAnswer(isYes: false)
    }
    
    func alertButtonTapped() {
        viewController?.resetImageBorder()
        resetGame()
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        // Сравниваем ответ пользователя с правильным ответом
        if isYes == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
    }
    
    
    func proceedWithAnswer(isYes: Bool) {
        didAnswer(isYes: isYes)
        let isCorrectAnswer = isYes == currentQuestion?.correctAnswer
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer)
        
        setButtonsEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionsOrFinish()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestions?) {
        guard let question = question else {
            print("Ошибка: Вопрос не загружен!")
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
            self?.setButtonsEnabled(true)
        }
    }
    
    func showNextQuestionsOrFinish() {
        if self.isLastQuestion() {
            finishQuiz()
        } else {
            showNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswersCount, total: questionsAmount)
        
        let totalAccuracy = statisticService?.totalAccuracy ?? 0
        let gameCount = statisticService?.gameCount
        let bestGame = statisticService?.bestGame
        
        let description = """
                Ваш результат: \(correctAnswersCount)/\(questionsAmount)
                Количество сыграных квизов: \(gameCount ?? 0)
                Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
        
        return description
    }
    
    func finishQuiz() {
        let description = makeResultsMessage()
        let result = QuizResultViewModel(
            title: "Этот раунд окончен!",
            description: description,
            buttonText: "Сыграть еще раз"
        )
        
        viewController?.showFinalResult(quiz: result)
        resetGame()
    }
    
    func showNextQuestion() {
        self.switchToNextQuestion()
        viewController?.resetImageBorder()
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
