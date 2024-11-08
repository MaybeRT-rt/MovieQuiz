//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 05.11.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0
    private var currentQuestion: QuizQuestions?
    private var alertDelegate: AlertPresenterDelegate?
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Initialization
    // Инициализация презентера, создаем зависимости внутри
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        // Инициализация зависимостей
        self.questionFactory = QuestionFactory(delegate: self, movieLoader: MoviesLoader(), questionGenerator: QuestionGenerator())
        self.statisticService = StatisticService()
    }
    
    // MARK: - Public Methods
    func loadDataForView() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        // Обновляем интерфейс
        viewController?.resetImageBorder()
        // Запускаем загрузку данных для новой игры
        loadDataForView()
    }
    
    func showNextQuestion() {
        switchToNextQuestion()
        viewController?.resetImageBorder()
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonTapped() {
        proceedWithAnswer(isYes: true)
    }
    
    func noButtonTapped() {
        proceedWithAnswer(isYes: false)
    }
    
    func finishQuiz() {
        let description = makeResultsMessage()
        let result = QuizResultViewModel(
            title: "Этот раунд окончен!",
            description: description,
            buttonText: "Сыграть еще раз"
        )
        viewController?.toggleAnswerButtons(false)
        showFinalResult(quiz: result)
    }
    
    func showFinalResult(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.description,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.resetGame()
            }
        )
        viewController?.showAlert(alertModel: alertModel)
    }
    
    func showNetworkError(message: String) {
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Поробовать еще раз", completion: { [weak self] in
            self?.resetGame()
        })
        
        viewController?.showAlert(alertModel: alertModel)
    }
    
    // Конвертируем модель вопроса в модель отображения
    func convert(model: QuizQuestions) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: (UIImage(data: model.image ?? Data()) ?? UIImage()),
            questions: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return question
    }
    
//    func didReceiveNextQuestion(question: QuizQuestions?) {
//        guard let question = question else {
//            print("Ошибка: Вопрос не загружен!")
//            return
//        }
//        currentQuestion = question
//        let viewModel = convert(model: question)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.viewController?.show(quiz: viewModel)
//            self?.viewController?.hideLoadingIndicator()
//            self?.setButtonsEnabled(true)
//        }
//    }
    
    // Обработка завершения загрузки данных с сервера
//    func didLoadDataFromServer() {
//        viewController?.hideLoadingIndicator()
//        questionFactory?.requestNextQuestion()
//    }
    
//    func didFailToLoadData(error: any Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    
    // MARK: - Private Methods
    
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Проверяет ответ пользователя и обновляет счетчик правильных ответов
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        // Сравниваем ответ пользователя с правильным ответом
        if isYes == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        viewController?.toggleAnswerButtons(isEnabled)
    }
    
    // Основной метод для обработки ответа пользователя
    func proceedWithAnswer(isYes: Bool) {
        didAnswer(isYes: isYes)
        let isCorrectAnswer = isYes == currentQuestion?.correctAnswer
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer)
        
        setButtonsEnabled(false) // Отключаем кнопки после ответа
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrFinish()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func showNextQuestionOrFinish() {
        if isLastQuestion() {
            finishQuiz()
        } else {
            showNextQuestion()
        }
    }
    
    // Создание сообщения с результатами для завершения квиза
    private func makeResultsMessage() -> String {
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
}

// MARK: - AlertPresenterDelegate
extension MovieQuizPresenter: AlertPresenterDelegate {
    
    func alertButtonTapped() {
        resetGame()
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    
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
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: Error){
        showNetworkError(message: error.localizedDescription)
    }
}
