//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 21.09.2024.
//

import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {

    // MARK: - IBOutlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestion: QuizQuestions?
  //  private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter = AlertPresenter()
   // private var statisticService: StatisticServiceProtocol = StatisticService()
    
    private lazy var presenter: MovieQuizPresenter = {
        return MovieQuizPresenter(viewController: self)
    }()
    
    //private var correctAnswersCount: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addAccessibilityIdentifier()
        
        alertPresenter.alertDelegate = self
        presenter.viewController = self

        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonTapped(_ sender: Any) {
        enabledNextButton(false)
        //presenter.currentQuestion = currentQuestion
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        enabledNextButton(false)
       // presenter.currentQuestion = currentQuestion
        presenter.noButtonTapped()
    }
    
    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        activityIndicator.hidesWhenStopped = true
        
        previewImage.layer.cornerRadius = 20
        
        setupButton(button: yesButton, title: "Да")
        setupButton(button: noButton, title: "Нет")
        
        setupText(textLabel: questionTitleLabel, fontName: "YSDisplay-Medium", size: 20)
        setupText(textLabel: indexLabel, fontName: "YSDisplay-Medium", size: 20)
        setupText(textLabel: questionLabel, fontName: "YSDisplay-Bold", size: 23)
    }
    
    private func addAccessibilityIdentifier() {
        previewImage.accessibilityIdentifier = "Poster"
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier = "No"
        indexLabel.accessibilityIdentifier = "Index"
    }
    
    // Настройка кнопок
    private func setupButton(button: UIButton, title: String) {
        button.layer.cornerRadius = 15
        button.tintColor = .ypBlack
        button.setTitle(title, for: .normal)
    }
    
    // Настройка лейблов
    private func setupText(textLabel: UILabel, fontName: String, size: CGFloat) {
        textLabel.font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        textLabel.textColor = .ypWhite
    }
    
    // MARK: - Logic
    // Отображаем текущий вопрос
    func show(quiz step: QuizStepViewModel) {
        previewImage?.isHidden = true // Скрываем старое изображение
        previewImage?.image = step.image
        questionLabel?.text = step.questions
        indexLabel?.text = step.questionNumber
        
        DispatchQueue.main.async {
            self.previewImage?.isHidden = false // Показываем новое изображение
            self.enabledNextButton(true)
            self.hideLoadingIndicator()
        }
    }
    
    // Отображаем результат викторины
    func showFinalResult(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.description, buttonText: result.buttonText, completion: { [weak self] in
            guard let self = self else { return }
            self.alertButtonTapped()
            }
        )
        alertPresenter.showAlert(on: self, with: alertModel)
    }
    
    func alertButtonTapped() {
        resetImageBorder()
        presenter.resetGame()
    }
    
    
    func didReceiveNextQuestion(question: QuizQuestions?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // Отображаем результат ответа (правильный или неправильный)
    func showResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self = self else { return }
            self.showLoadingIndicator()
           // self.presenter.correctAnswersCount = self.presenter.correctAnswersCount
            //self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionsOrFinish()
        }
    }
    
    func resetImageBorder() {
        previewImage.layer.borderWidth = 0
        previewImage.layer.borderColor = nil
    }
    
    private func enabledNextButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
       // hideLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка", message: message, buttonText: "Поробовать еще раз", completion: { [weak self] in
            guard let self = self else { return }
            
            presenter.resetGame()
            //presenter.resetCorrectAnswersCount()
            //presenter.questionFactory?.requestNextQuestion()
        })
        
        alertPresenter.showAlert(on: self, with: alert)
    }
}

