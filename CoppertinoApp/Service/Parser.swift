//
//  Parser.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/5/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import Foundation


class Parser {
    
    class func parseAlbumData(data: Data, completion: @escaping (String?, Error?) -> Void) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            let data = (json as? NSDictionary)?["album"] as? NSArray
            
            if data == nil {
                completion(nil, SearchError.nilSearchResult)
                return
            }
            
            if let album = data!.firstObject as? [String: Any],
                let imageUrl = album["strAlbumThumb"] as? String {
                completion(imageUrl, nil)
            } else {
                completion(nil, SearchError.invalidParsing)
            }
        } catch {
            completion(nil, SearchError.invalidParsing)
        }
    }

}
