import UIKit

struct QuizQuestions {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let image: UIImage
    let questions: String
    let questionNumber: String
}

struct QuizResultViewModel {
    let title: String
    let description: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    private let questions: [QuizQuestions] = [
        QuizQuestions(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestions(image: "The Dark Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Kill Bill",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "The Avengers",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Deadpool",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "The Green Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestions(image: "Old",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "The Ice Age Adventures of Buck Wild",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "Tesla",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestions(image: "Vivarium",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        
    ]
    
    
    // MARK: - IBOutlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    
    private var currentQuestionIndex = 0 // индекс
    private var correctAnswersCount: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let currentQuestion = questions[currentQuestionIndex]
        let quizStepViewModel = convert(model: currentQuestion)
        show(quiz: quizStepViewModel)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonTapped(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let correctAnswer = true
        if correctAnswer == currentQuestion.correctAnswer {
            correctAnswersCount += 1
        }
        
        showResult(isCorrect: correctAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
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
    
    private func setupButton(button: UIButton, title: String) {
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        button.tintColor = .ypBlack
        button.setTitle(title, for: .normal)
    }
    
    private func setupText(textLabel: UILabel, fontName: String, size: CGFloat) {
        textLabel.font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        textLabel.textColor = .ypWhite
    }
    
    // MARK: - Logic
    private func convert(model: QuizQuestions) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            questions: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return question
    }
    
    private func show(quiz step: QuizStepViewModel) {
        previewImage?.image = step.image
        questionLabel?.text = step.questions
        indexLabel?.text = step.questionNumber
    }
    
    private func showResult(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(title: result.title, message: result.description, preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.previewImage.layer.borderWidth = 0
            let viewModel = self.convert(model: self.questions[self.currentQuestionIndex])
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    private func showResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionsOrFinish()
        }
    }
    
    private func showNextQuestionsOrFinish() {
        if currentQuestionIndex == questions.count - 1 {
            let description = "Вы ответили правильно на \(correctAnswersCount) из \(questions.count) вопросов"
            let result = QuizResultViewModel(title: "Результат", description: description, buttonText: "Попробовать еще раз")
            correctAnswersCount = 0
            showResult(quiz: result)
        } else {
            currentQuestionIndex += 1
            previewImage.layer.borderWidth = 0
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
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
