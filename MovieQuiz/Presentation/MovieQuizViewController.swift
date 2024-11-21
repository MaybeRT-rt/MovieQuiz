//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 21.09.2024.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter = AlertPresenter()
    
    private lazy var presenter: MovieQuizPresenter = {
        return MovieQuizPresenter(viewController: self)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addAccessibilityIdentifier()
        presenter.loadDataForView()
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.noButtonTapped()
    }
    
    // MARK: - Public Methods
    
    func didReceiveNextQuestion(question: QuizQuestions?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // MARK: - Private Methods
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
}

// MARK: - MovieQuizViewControllerProtocol

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    // MARK: - Displaying Data
    func show(quiz step: QuizStepViewModel) {
        previewImage?.isHidden = true // Скрываем старое изображение
        previewImage?.image = step.image
        questionLabel?.text = step.questions
        indexLabel?.text = step.questionNumber
        
        DispatchQueue.main.async { [weak self] in
            self?.previewImage?.isHidden = false // Показываем новое изображение
            self?.toggleAnswerButtons(true)
            self?.hideLoadingIndicator()
        }
    }
    
    func showAlert(alertModel: AlertModel) {
        alertPresenter.showAlert(on: self, with: alertModel)
    }
    
    // MARK: - UI Interaction
    func toggleAnswerButtons(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - UI State Updates
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func resetImageBorder() {
        previewImage.layer.borderWidth = 0
        previewImage.layer.borderColor = nil
    }
}
