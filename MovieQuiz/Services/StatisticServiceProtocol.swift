//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 11.10.2024.
//

protocol StatisticServiceProtocol {
    var gameCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
