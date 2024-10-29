//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 08.10.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestions?)
    func didLoadDataFromServer()
    func didFailToLoadData(error: Error)
}
