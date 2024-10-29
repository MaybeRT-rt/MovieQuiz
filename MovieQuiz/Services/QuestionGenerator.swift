//
//  QuestionGenerator.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 29.10.2024.
//

final class QuestionGenerator: QuestionGeneratorProtocol {
    
    func generateQuestion(for movie: MostPopularMovie) -> QuizQuestions? {
        guard let rating = Float(movie.rating) else { return nil }
        
        let question: [(condition: (Float) -> Bool, text: String)] = [
            ({ $0 < 7 }, "Рейтинг этого фильма меньше чем 7?"),
            ({ $0 >= 8 }, "Рейтинг этого фильма больше или равен 8?"),
            ({ $0 < 8 }, "Рейтинг этого фильма меньше чем 8?"),
            ({ $0 >= 8.5 }, "Рейтинг этого фильма больше или равен 8.5?"),
            ({ $0 < 8.5 }, "Рейтинг этого фильма меньше чем 8.5?"),
            ({ $0 >= 9 }, "Рейтинг этого фильма больше или равен 9?"),
            ({ $0 < 9 }, "Рейтинг этого фильма меньше чем 9?")
        ]
        
        // Генерация случайного вопроса
        let questionRandom = question.randomElement()
        // Проверка условия для правильного ответа
        let correctAnswer = questionRandom?.condition(rating) ?? false
        // Формирование текста вопроса
        let text = questionRandom?.text ?? ""
        
        return QuizQuestions(image: nil, text: text, correctAnswer: correctAnswer)
    }
}
