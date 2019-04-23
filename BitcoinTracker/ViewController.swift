//
//  ViewController.swift
//  BitcoinTracker
//
//  Created by Apple on 31/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SwiftChart
class ViewController: UIViewController , ChartDelegate{
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        //
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        //
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //
    }
    
    
    @IBOutlet weak var chartView: Chart!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    
    var arrayUSD: [Double] = [4000.00]
    var arrayINR: [Double] = [280000.00]
    struct Prices : Decodable {
        let bpi: [String : Bpi]
    }
    struct Bpi : Decodable{
        let code:String?
        let rate_float:Double?
    }
    
    func updatechart(rateValue:Double, codeArray: inout [Double]) {
        if codeArray.count > 20{
            codeArray.remove(at: 0)
        }
        codeArray.append(rateValue)
        let series = ChartSeries(codeArray)
        series.color = ChartColors.goldColor()
        series.area=true
        chartView.removeAllSeries()
        chartView.add(series)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       getPrice()
        chartView.delegate=self
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getPrice), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func getPrice(){
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/INR.json")
        URLSession.shared.dataTask(with: url!){ data,response,error in
            if error != nil{
                print(error!.localizedDescription)
            }
            if let data = data{
                print(String(data:data,encoding: .utf8))
                let price = try? JSONDecoder().decode(Prices.self, from:data)
                let bpi = price?.bpi
                let codeUSD = bpi!["USD"]!.code
                let rateUSD = bpi!["USD"]!.rate_float!
                let rateINR = bpi!["INR"]!.rate_float!
                DispatchQueue.main.async {
                    if self.segmentedController.selectedSegmentIndex == 0{
                        self.label.text = "\(rateUSD)"
                        self.updatechart(rateValue: rateUSD, codeArray: &self.arrayUSD)
                    }
                    else {
                        self.label.text="\(rateINR)"
                        self.updatechart(rateValue: rateINR,codeArray: &self.arrayINR)
                    }
                }
               
            }
            
        }.resume()
        
    }
   
    struct bpiDate: Decodable{
        let date:String?
        let rate_float:Double?
    }
    struct Data : Decodable {
        let bpi: [bpiDate]
    }
    
    func getPriceByDate(){
        
        let url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=USD")
        URLSession.shared.dataTask(with: url!){ data,response,error in
            if error != nil{
                print(error!.localizedDescription)
            }
            if let data = data{
                print(String(data:data,encoding: .utf8))
                let data = try? JSONDecoder().decode(Prices.self, from:data)
                let bpi = data?.bpiDate
                let date = bpi.da
                let rateUSD = bpi!["USD"]!.date!
                let rateINR = bpi!["INR"]!.rate_float!
                DispatchQueue.main.async {
                    if self.segmentedController.selectedSegmentIndex == 0{
                        self.label.text = "\(rateUSD)"
                        self.updatechart(rateValue: rateUSD, codeArray: &self.arrayUSD)
                    }
                    else {
                        self.label.text="\(rateINR)"
                        self.updatechart(rateValue: rateINR,codeArray: &self.arrayINR)
                    }
                }
                
            }
            
            }.resume()
        
    }

    
    @IBAction func bttnClick(_ sender: Any) {
        getPrice()
    }
    
}

