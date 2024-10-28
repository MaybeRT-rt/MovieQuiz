//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 11.10.2024.
//

import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount, bestGameCorrect, bestGameTotal, bestGameDate, correctAnswers, totalAnswers
    }
}

extension StatisticService: StatisticServiceProtocol {
    
    var gameCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var correct: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var total: Int {
        get {
            storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalAnswers.rawValue)
            return totalQuestions > 0 ? (Double(correctAnswers) / Double(totalQuestions)) * 100 : 0
        }
    }
    
    
    func store(correct count: Int, total amount: Int) {
        gameCount += 1
        
        // Обновляем количество правильных ответов
        let currentCorrectAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        storage.set(currentCorrectAnswers + count, forKey: Keys.correctAnswers.rawValue)
        
        // Обновляем общее количество вопросов
        let currentTotal = storage.integer(forKey: Keys.totalAnswers.rawValue)
        storage.set(currentTotal + amount, forKey: Keys.totalAnswers.rawValue)
        
        // Проверяем, является ли текущая игра лучшей
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isCorrect(bestGame) {
            bestGame = currentGameResult
        }
    }
}
