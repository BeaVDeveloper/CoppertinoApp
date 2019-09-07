//
//  HistoryTableViewController.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import UIKit

protocol HistoryRequestDelegate {
    func didSelectRequest(_ request: SearchRequest)
}

class HistoryTableViewController: UITableViewController {
    //MARK: - Constants
    private let searchCellId = "searchResultCell"
    private let headerHeight: CGFloat = 30
    private let cellHeight: CGFloat = 50
    
    private let elementPerRequest: Int = 10
    
    private var offset = 0
    
    private let database = DatabaseManager.shared
    private var requests: [[SearchRequest]] = []
    
    var delegate: HistoryRequestDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.backgroundColor = .clear
        
        database.delegate = self
        
        requests = database.fetchHistoryRequests(0)
    }
    
    //MARK: - Header setup methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let itemsOfDay = requests[section].first else { return nil }
        let header = UIView()
        header.layer.cornerRadius = 15
        header.backgroundColor = #colorLiteral(red: 0.4145628512, green: 0.8097560406, blue: 0.833901763, alpha: 0.77)
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.width, height: 30))
        label.text = itemsOfDay.date!.toHistoryString()
        header.addSubview(label)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let first = requests.first, first.count > 0 {
            return requests.count
        }
        return 0
    }

    //MARK: - Cell setup methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId, for: indexPath) as? RequestCell else { return UITableViewCell() }
        let request = requests[indexPath.section][indexPath.row]
        cell.configureCell(with: request)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    //MARK: Scroll & row selection
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //MARK: - Calculation scroll offset for pagination
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let maximumOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= cellHeight {
            
            var allRequests: [SearchRequest] = []
            requests.forEach({allRequests.append(contentsOf: $0)})
            if allRequests.count >= elementPerRequest {
                offset = offset + elementPerRequest
                let newData = DatabaseManager.shared.fetchHistoryRequests(offset)
                
                //MARK: - Merge search requests with pagination
                
                /*
                 Get last day with array requests before appending new data, I should check that new incoming data could be with the same day of search (to merge, if it is), so I need to compare history string of last day with incoming day, so i get first day array of new data (no metter wich element of day array I will get, they all will be with the same day), get element and compare, if match, I create new day array with last day of 'old' data + first day of 'new' data, else just append new days to array.
                 */
                
                guard let firstItem = newData.first?.first, let lastItemOfLastDay = requests.last?.last else { return }
                
                if lastItemOfLastDay.date!.toHistoryString() == firstItem.date!.toHistoryString() {
                    let updatedData = requests.removeLast() + newData.first!
                    requests.append(updatedData)
                } else {
                    requests += newData
                }
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRequest = requests[indexPath.section][indexPath.row]
        delegate?.didSelectRequest(selectedRequest)
    }
}

extension HistoryTableViewController: DatabaseDelegate {
    func updateData() {
        // reset offset to fetch data from the beggining
        offset = 0
        requests = DatabaseManager.shared.fetchHistoryRequests(offset)
    }
    
    func failedFetchData(error: SearchError) {
        Alert.showAlert(with: error.errorDescription!, in: self)
    }
}
