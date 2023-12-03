//
//  ViewController.swift
//  PopularSearcherApp
//
//  Created by 김태성 on 12/3/23.
//

import UIKit
import Foundation
import SwiftSoup

struct NateModel {
    var number: Int
    var word: String
}

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var btnStart: UIButton!
    let cellIdentifier = "MyCell"
    var myData = ["사과", "당근", "카카오", "샐러드","사과", "당근", "카카오", "샐러드","사과", "당근"]
    var nateSearches: [NateModel] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.myTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = myData[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = self.myTableView.indexPath(for: cell)
            let detailView = segue.destination as! ModalViewController
            detailView.selectedWord(myData[((indexPath! as NSIndexPath).row)])
        }
    }
    
    @IBAction func startSearch(_ sender: UIButton) {
        fetchHTMLParsingFromNate{}

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [self] in
            for i in 0..<self.nateSearches.count {

                myData[i] = nateSearches[i].word.replacingOccurrences(of: "\"", with: "")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
          // 1초 후 실행될 부분
            self.myTableView.reloadData()
            print(self.myData)
        }
    }
    
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        self.imgView.image = UIImage(named: "imgNate")
        // Do any additional setup after loading the view.
    }

    func fetchHTMLParsingFromNate(completion: @escaping () -> ()) {
        nateSearches.removeAll()
        let urlAddress = "https://www.nate.com/js/data/jsonLiveKeywordDataV1.js?v="
        
        guard let url = URL(string: urlAddress) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: ", error)
                completion()
                return
            }

            if let data = data, let html = String(data: data, encoding: .eucKrDecode) {
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    let b = try doc.select("body").first()!.text()
                    print(b, terminator: "\n")
                    
                    var arr = b.split(separator: "]")
                    for i in 0..<arr.count {
                        let word = arr[i].split(separator: ",")[1]
                        print(word)
                        
                        self.nateSearches.append(NateModel.init(number: i, word: String(word)))
                    }
                } catch let error {
                    print("ERROR: ", error)
                }
            }

            completion()
        }

        task.resume()
        
    }
}



extension String.Encoding {
    static let eucKrDecode = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
}

extension String {
    func bytesByRemovingPercentEncoding(using encoding: String.Encoding) -> Data {
        struct My {
            static let regex = try! NSRegularExpression(pattern: "(%[0-9A-F]{2})|(.)", options: .caseInsensitive)
        }
        var bytes = Data()
        let nsSelf = self as NSString
        for match in My.regex.matches(in: self, range: NSRange(0..<self.utf16.count)) {
            if match.range(at: 1).location != NSNotFound {
                let hexString = nsSelf.substring(with: NSMakeRange(match.range(at: 1).location+1, 2))
                bytes.append(UInt8(hexString, radix: 16)!)
            } else {
                let singleChar = nsSelf.substring(with: match.range(at: 2))
                bytes.append(singleChar.data(using: encoding) ?? "?".data(using: .ascii)!)
            }
        }
        return bytes
    }
    func removingPercentEncoding(using encoding: String.Encoding) -> String? {
        return String(data: bytesByRemovingPercentEncoding(using: encoding), encoding: encoding)
    }
}
