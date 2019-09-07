//
//  Service.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/5/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import Foundation
import Alamofire
import Network

class Service {
    
    static let shared = Service()

    private let monitor = NWPathMonitor()
    private let API_KEY = "1"
    
    private init() {
        //Check Internet connection
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
            } else {
                print("No connection.")
            }
        }
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    private func request(url: String, method: HTTPMethod, parameters: Parameters, completion: @escaping (Data?, Error?) -> Void) {
        Alamofire.request(url, method: method, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(response.data, nil)
                case .failure(let error):
                    if self.monitor.currentPath.status == .unsatisfied || self.monitor.currentPath.status == .requiresConnection {
                        completion(nil, SearchError.internetConnectionFailed)
                        return
                    }
                    completion(response.data, error)
                }
        }
    }
    
    func getSingleAlbum(artistName: String, albumName: String, completion: @escaping (Data?, Error?) -> Void) {
        
        let SEARCH_URL = "http://theaudiodb.com/api/v1/json/1/searchalbum.php"
        
        let parameters = ["s": artistName, "a": albumName]
        
        request(url: SEARCH_URL, method: .get, parameters: parameters) { (data, error) in
            completion(data, error)
        }
    }
}
