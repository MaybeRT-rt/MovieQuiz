//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Liz-Mary on 01.11.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    // Метод, который выполняется перед каждым тестом
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Инициализация приложения для UI-тестов
        app = XCUIApplication()
        // Запуск приложения
        app.launch()
        
        // Остановка тестов при первой ошибке
        continueAfterFailure = false
    }
    
    // Метод, который выполняется после каждого теста
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Завершение приложения после теста
        app.terminate()
        // Освобождение ресурса приложения
        app = nil
    }
    
    @MainActor
    func testYesButton() {
        // Проверка наличия кнопки "Да" на экране
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5), "Button 'Yes' did not appear in time")
        
        // Проверка наличия первого постера на экране
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "First poster did not appear in time")
        
        // Сохранение изображения первого постера
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // Клик по кнопке "Да"
        yesButton.tap()
        
        // Задержка для асинхронного обновления
        sleep(2)
        // Проверка наличия второго постера после нажатия "Да"
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Second poster did not appear in time after tapping 'Yes'")
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        // Проверка, что постеры различаются
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Poster did not change after tapping 'Yes'")
    }
    
    @MainActor
    func testNoButton() {
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5), "Button 'No' did not appear in time")

        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "First poster did not appear in time")
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        noButton.tap()
        
        sleep(2)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Next poster did not appear in time")

        XCTAssertNotEqual(firstPosterData, secondPosterData, "Poster did not change after tapping 'No'")
    }
    
    @MainActor
    func testGameFinish() {
        // Имитация завершения игры путем нажатия на кнопку "Нет" 10 раз
        for _ in 1...10 {
            app.buttons["No"].tap()
            // Задержка для обработки каждого нажатия
            sleep(2)
        }

        // Проверка появления алерта о завершении игры
    
        let alert = app.alerts["GameResult"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert 'GameResult' did not appear in time.")
        // Проверка текста алерта
        XCTAssertTrue(alert.label == "Этот раунд окончен!", "Alert label did not match expected text.")
        // Проверка наличия кнопки "Сыграть еще раз" с установленным идентификатором
        let retryButton = alert.buttons["retryButton"]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5), "Retry button did not appear in time.")
        
        // Проверка текста кнопки
        XCTAssertTrue(retryButton.label == "Сыграть еще раз", "Button label did not match expected text.")
        XCTAssertTrue(retryButton.isHittable, "Retry button is not hittable.")
    }
    
    @MainActor
    func testAlertDismiss() {
        // Имитируем завершение игры
        sleep(5)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(5)
        }
        // Проверка появления алерта о завершении игры
        let alert = app.alerts["GameResult"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert did not appear in time")
        // Закрытие алерта
        alert.buttons.firstMatch.tap()

        sleep(5)
        // Проверка обновления индекса вопросов
        let indexLabel = app.staticTexts["Index"]
        
        // Проверка, что алерт был закрыт и индекс обновился
        XCTAssertFalse(alert.exists, "Alert should be dismissed but still exists")
        XCTAssertTrue(indexLabel.label == "1/10", "Expected index label to be '1/10', but got: \(indexLabel.label)")
    }
}
