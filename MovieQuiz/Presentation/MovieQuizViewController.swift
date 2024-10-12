import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestions?
    private var questionFactory:  QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter = AlertPresenter()
    private let statisticService = StatisticService()
    
    private var currentQuestionIndex = 0 // индекс
    private var correctAnswersCount: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestions?) {
        guard let question = question else {
                return
            }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonTapped(_ sender: Any) {
        enabledNextButton(false)
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = true
        if correctAnswer == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
        showResult(isCorrect: correctAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        enabledNextButton(false)
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = false
        if correctAnswer == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
        showResult(isCorrect: correctAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .ypBlack
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.cornerRadius = 20
        
        setupButton(button: yesButton, title: "Да")
        setupButton(button: noButton, title: "Нет")
        
        setupText(textLabel: questionTitleLabel, fontName: "YSDisplay-Medium", size: 20)
        setupText(textLabel: indexLabel, fontName: "YSDisplay-Medium", size: 20)
        setupText(textLabel: questionLabel, fontName: "YSDisplay-Bold", size: 23)
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
    
    // Конвертируем модель вопроса в модель отображения
    private func convert(model: QuizQuestions) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            questions: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return question
    }
    
    // Отображаем текущий вопрос
    private func show(quiz step: QuizStepViewModel) {
        previewImage?.image = step.image
        questionLabel?.text = step.questions
        indexLabel?.text = step.questionNumber
        
        enabledNextButton(true)
    }
    
    // Отображаем результат викторины
    private func showFinalResult(quiz result: QuizResultViewModel) {
        let alertPresenter = AlertPresenter()
        alertPresenter.alertDelegate = self
        
        let alertModel = AlertModel(title: result.title, message: result.description, buttonText: result.buttonText, completion: { [weak self] in
            guard let self = self else { return }
            self.alertButtonTapped()
            }
        )
        alertPresenter.showAlert(on: self, with: alertModel)
    }
    
    func alertButtonTapped() {
        self.currentQuestionIndex = 0
        resetImageBorder()
        questionFactory.requestNextQuestion()
    }
    
    // Отображаем результат ответа (правильный или неправильный)
    private func showResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self = self else { return }
            self.showNextQuestionsOrFinish()
        }
    }
    
    private func resetImageBorder() {
        previewImage.layer.borderWidth = 0
        previewImage.layer.borderColor = nil
    }
    
    private func showNextQuestionsOrFinish() {
        if currentQuestionIndex == questionsAmount - 1 {
            // Завершение викторины: обновляем статистику
            statisticService.store(correct: correctAnswersCount, total: questionsAmount)
            
            // Получаем общую точность и количество игр из сервиса статистики
            let totalAccuracy = statisticService.totalAccuracy
            let gameCount = statisticService.gameCount
            let bestGame = statisticService.bestGame
            
            // Описание текущей игры и статистики
            let description = """
            \(correctAnswersCount == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswersCount) из 10, попробуйте ещё раз!")
            
            Всего сыграно игр: \(gameCount)
            Ваша лучшая игра: \(bestGame.correct)/\(bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Общая точность: \(String(format: "%.2f", totalAccuracy))%
            """
            
            // Создаем результат для отображения в алерте
            let result = QuizResultViewModel(title: "Результат", description: description, buttonText: "Попробовать еще раз")
            
            // Показываем финальный результат
            showFinalResult(quiz: result)
            
            // Сбрасываем счетчик правильных ответов
            correctAnswersCount = 0
        } else {
            // Если это не последний вопрос, продолжаем викторину
            currentQuestionIndex += 1
            resetImageBorder()
            questionFactory.requestNextQuestion()
        }
    }
    
    private func enabledNextButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
