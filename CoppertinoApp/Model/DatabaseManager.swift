//
//  DatabaseManager.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import UIKit
import CoreData

protocol DatabaseDelegate {
    func updateData()
    func failedFetchData(error: SearchError)
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private var managedContext: NSManagedObjectContext?
    
    var delegate: DatabaseDelegate?
    
    private init() {
        managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    private let limit: Int = 10
    
    func saveRequest(text searchedText: String, date: Date, complition: @escaping (SearchError?) -> Void) {
        guard let context = managedContext else { return }
        let searchRequest = SearchRequest(context: context)
        searchRequest.date = date
        searchRequest.text = searchedText
        
        do {
            try context.save()
            complition(nil)
            // Tells HistoryTableView to fetch data from DB and update tableView data
            delegate?.updateData()
        } catch {
            complition(SearchError.saveFailed)
        }
    }
    
    func fetchHistoryRequests(_ offset: Int) -> [[SearchRequest]] {
        guard let context = managedContext else { return [] }
        
        let fetchRequest = NSFetchRequest<SearchRequest>(entityName: "SearchRequest")
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset
        //Fetch sorted by date
        let sort = NSSortDescriptor(key: #keyPath(SearchRequest.date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            let data = try context.fetch(fetchRequest)
            //No reason to sort, return element
            guard data.count > 1 else { return [data] }
            
            return sortByDays(requests: data)
        } catch {
            delegate?.failedFetchData(error: SearchError.fetchFailed)
            return []
        }
    }
    
    /*
     sortByDays method return Two-dimensional array in wich every element or second-dimension array ([SearchRequest]) refer for specific day, in wich all elements (SearchRequest) will be with the same day of search.
 */
    private func sortByDays(requests: [SearchRequest]) -> [[SearchRequest]] {
        
        var startPoint = requests.first!
        
        var outputArray: [[SearchRequest]] = []
        
        /*
        startPoint - last search request in DB data, because of sort descriptor (see above), later will be changed, when request from past day will be found, to found one.
         
        Compare each request's day/month/year to startPoint's day/month/year, if it's less - I can figure out that request was in past, and append new day array with all requests that have been send in that particular day (from startPoint index to i, excluding, couse i refers to another day)
            else if the iterated request is the last one of recieved, append elements from startPoint index to i, including.
         */
        
        for i in 1..<requests.count {
            let request = requests[i]
            let start = startPoint.date!.getDateInfo() // returns (day: n, month: n, year: n)
            let current = request.date!.getDateInfo() // same
            guard let index = requests.firstIndex(of: startPoint) else { return [] }
            
            if current.day < start.day || current.month < start.month || current.year < start.year {
                let array = Array(requests[index..<i])
                outputArray.append(array)
                startPoint = requests[i]
            } else if request == requests.last! {
                let array = Array(requests[index...i])
                outputArray.append(array)
            }
        }
        return outputArray
    }
}

