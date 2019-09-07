//
//  ViewController.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/5/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import UIKit
import JGProgressHUD
import CoreData

class SearchViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var albumImage: CustomImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    
    private let service = Service.shared
    
    private let restrictedStr = "-:–|~\\/ "
    
    private var hud = JGProgressHUD(style: .dark)
    
    private var childView: HistoryTableViewController {
        return children.last as! HistoryTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.returnKeyType = .search
        childView.delegate = self
    }
    
    @IBAction func historyTapped(_ sender: UIButton) {
        view.endEditing(true)
        performTransition(toHistory: albumImage.isHidden ? false : true)
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        view.endEditing(true)
        performTransition(toHistory: false)
        
        guard let artist = prepareSearchTextForService().artistName, let albumName = prepareSearchTextForService().albumName else { return }
        hud.textLabel.text = "Searching..."
        hud.show(in: view)

        service.getSingleAlbum(artistName: artist, albumName: albumName) { (data, error) in
            guard !self.isError(error: error) else { return }
            
            Parser.parseAlbumData(data: data!, completion: { (imageUrl, error) in
                guard !self.isError(error: error) else { return }
                
                self.updateImage(with: imageUrl!)
                
                DatabaseManager.shared.saveRequest(text: self.searchTextField.text!, date: Date(), complition: { (error) in
                    if error != nil {
                        Alert.showAlert(with: error!.errorDescription!, in: self)
                    }
                })
            })
        }
    }
    
    private func performTransition(toHistory: Bool) {
        if toHistory {
            guard albumImage.isHidden == false else { return }
            childView.tableView.reloadData()
        } else {
            guard containerView.isHidden == false else { return }
        }
        
        UIView.transition(from: toHistory ? albumImage : containerView, to: toHistory ? containerView : albumImage, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        
        if toHistory {
            albumImage.isHidden = true
        } else {
            containerView.isHidden = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func updateImage(with url: String) {
        self.albumImage.loadImage(urlString: url)
        UIView.animate(withDuration: 1.0, animations: {
            self.albumImage.alpha = 1
        })
        self.hud.dismiss()
    }
    
    private func prepareSearchTextForService() -> (artistName: String?, albumName: String?) {
        let text = searchTextField.text ?? ""
        let separators = restrictedStr.prefix(restrictedStr.count - 1)
        
        var artistName = ""
        var albumName = ""
        
        for separator in separators {
            let strArray = text.split(separator: separator)
            if strArray.count > 2 {
                Alert.showAlert(with: SearchError.nilSearchResult.errorDescription!, in: self)
                return (nil, nil)
            } else if strArray.count == 2 {
                
                artistName = String(strArray.first!)
                albumName = String(strArray.last!)
                
                if artistName.last == " " {
                    artistName.removeLast()
                }
                if albumName.first == " " {
                    albumName.removeFirst()
                }
                
                if albumName.last == " " {
                    albumName.removeLast()
                }
                
                return (artistName, albumName)
            }
        }
        Alert.showAlert(with: SearchError.nilSearchResult.errorDescription!, in: self)
        return (nil, nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func isError(error: Error?) -> Bool {
        var message = ""
        if error != nil {
            if let searchError = error as? SearchError {
                message = searchError.errorDescription!
            } else {
                message = "Try one more time"
            }
            hud.dismiss()
            Alert.showAlert(with: message, in: self)
            return true
        }
        return false
    }

}

extension SearchViewController: UITextFieldDelegate {
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = searchTextField.text ?? ""
        let charSet = CharacterSet(charactersIn: restrictedStr)
        
        if currentText.isEmpty {
            return string.rangeOfCharacter(from: charSet) == nil
        }

        if let last = currentText.last, restrictedStr.contains(string), restrictedStr.contains(last), string == String(last) {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped(searchButton)
        return true
    }
}

extension SearchViewController: HistoryRequestDelegate {
    func didSelectRequest(_ request: SearchRequest) {
        searchTextField.text = request.text
        performTransition(toHistory: false)
        searchTapped(searchButton)
    }
}

