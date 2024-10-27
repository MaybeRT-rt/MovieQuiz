//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 11.10.2024.
//
import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isCorrect(_ anotherTotal: GameResult) -> Bool {
        if self.correct > anotherTotal.correct {
            return true
        } else if self.correct == anotherTotal.correct {
            // Если количество правильных ответов одинаково, сравниваем по дате
            return self.date > anotherTotal.date
        }
        return false
    }
}
