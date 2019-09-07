//
//  ErrorExtension.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import Foundation

enum SearchError: Error {
    case invalidParsing
    case internetConnectionFailed
    case nilSearchResult
    case saveFailed
    case fetchFailed
}

extension SearchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidParsing:
            return NSLocalizedString("Unable to parse JSON, because of wrong keys", comment: "Invalid Parsing")
        case .internetConnectionFailed:
            return NSLocalizedString("Problems with internet connection occurs", comment: "Internet connection failed")
        case .nilSearchResult:
            return NSLocalizedString("No results were found for your request. Please make sure your request is right" + "\n Search example: \n “Queen - Bohemian rhapsody”, “The Beatles : Abbey Road”", comment: "Emty search result")
        case .saveFailed:
            return NSLocalizedString("Falied to save your request to history", comment: "Database failed")
        case .fetchFailed:
            return NSLocalizedString("Failed to fetch your history data", comment: "Database falied")
        }
    }
}

