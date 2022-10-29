//
//  ViewController.swift
//  NEOFinder
//
//  Created by Gobinath on 29/10/22.
//

import UIKit
import Charts

class ViewController: UIViewController,neoManagerDelegate {
       
    @IBOutlet weak var startDateLbl: UITextField!
    
    @IBOutlet weak var endDateLbl: UITextField!
    
    @IBOutlet weak var datesPickerView: UIDatePicker!
    
    @IBOutlet weak var neoBarChatView: BarChartView!
    @IBOutlet weak var fatestAstroidIDSpeed: UILabel!
    @IBOutlet weak var fatestAsteriodID: UILabel!
    
    @IBOutlet weak var closestAsteriodID: UILabel!
    
    @IBOutlet weak var closestAsteriodDistance: UILabel!
    
    @IBOutlet weak var avgSize: UILabel!
    
    var isStartDate : Bool!
    var neoManagerObj = neoAPIManager()
    var asteriodsCollection = [Asteriod]()
    var countOfAsteriodPerDay = [Int]()
    var availableDates = [String]()
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var pickerdonebtn: UIButton!
    
    @IBOutlet weak var pickerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Near Earth Objects"
        datesPickerView.isHidden = true
        datesPickerView.datePickerMode = .date
        datesPickerView.preferredDatePickerStyle = .wheels
        datesPickerView.maximumDate = Date()
        neoManagerObj.delegate = self
        pickerContainerView.isHidden = true
        loader.isHidden = true
        
    }
    
    @IBAction func searchNeo(_ sender: Any) {
       
        loader.isHidden = false
        loader.startAnimating()
        neoManagerObj.fetchNEOs(startDate: startDateLbl.text!, endDate: endDateLbl.text!)
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        if isStartDate {
            startDateLbl.text = formatter.string(from: datesPickerView.date)
        }else{
            endDateLbl.text = formatter.string(from: datesPickerView.date)
        }
        datesPickerView.isHidden = true
        pickerdonebtn.isHidden = true
    }
    
    
    @IBAction func startAction(_ sender: Any) {
        isStartDate = true
        pickerContainerView.isHidden = false
        datesPickerView.isHidden = false
        startDateLbl.inputView = datesPickerView
        pickerdonebtn.isHidden = false
    }
    
    @IBAction func endAction(_ sender: Any) {
        isStartDate = false
        pickerContainerView.isHidden = false
        datesPickerView.isHidden = false
        endDateLbl.inputView = datesPickerView
        pickerdonebtn.isHidden = false
    }
    
    func didUpdateNEO(_ NEOManager: neoAPIManager, neoObj: NEOResponse) {
        let allDates = neoObj.nearEarthObjects.keys
        var dateswiseObj = [[Asteriod]]()
        for dates in allDates {
            dateswiseObj.append(neoObj.nearEarthObjects[dates] ?? [])
            availableDates.append(dates)
            
        }
        for datawiseObjs in dateswiseObj {
            
            countOfAsteriodPerDay.append(datawiseObjs.count)
            for individual in datawiseObjs {
                
                asteriodsCollection.append(individual)
            }
        }
        
        //  print("The count = \(countOfAsteriodPerDay)")
        
        // Find Closest
        asteriodsCollection = asteriodsCollection.sorted { a, b in
            let firstValue = Double(a.closeApproachData.first?.missDistance.kilometers ?? "") ?? 0.0
            let secondValue = Double(b.closeApproachData.first?.missDistance.kilometers ?? "") ?? 0.0
            return firstValue < secondValue
            
        }
        
        DispatchQueue.main.async {
            self.closestAsteriodID.text = self.asteriodsCollection.first?.id
            let kms = self.asteriodsCollection.first?.closeApproachData
            self.closestAsteriodDistance.text = kms?.first?.missDistance.kilometers
        }
        
        //Find Fastest
        asteriodsCollection = asteriodsCollection.sorted { a, b in
            
            let firstValue = Double(a.closeApproachData.first?.relativeVelocity.kmPerHour ?? "0.0") ?? 0.0
            let secondValue = Double(b.closeApproachData.first?.relativeVelocity.kmPerHour ?? "0.0") ?? 0.0
            return firstValue > secondValue
        }
        
        DispatchQueue.main.async {
            self.fatestAsteriodID.text = self.asteriodsCollection.first?.id
            let kms = self.asteriodsCollection.first?.closeApproachData
            self.fatestAstroidIDSpeed.text = kms?.first?.relativeVelocity.kmPerHour
        }
        
        //Find Avg Size
        var totalDiameter = 0.0
        let newasteriodsCollection = asteriodsCollection.map { a in
            totalDiameter = totalDiameter + a.estimatedDiameter.kilometers.maxEstimatedDiameter
        }
        let avgSizeValue = totalDiameter/Double(asteriodsCollection.count)
        
        DispatchQueue.main.async {
            self.avgSize.text = String(avgSizeValue)
            self.setDataCount()
            self.loader.isHidden = true
            self.loader.stopAnimating()
        }
        
    }

    func didFailWithError(error: Error) {
      
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.loader.stopAnimating()
            self.errorAlert(errorDescr: error.localizedDescription)
        }
        
    }
    
    func setDataCount() {
        let start = 0
        let yVals = (start..<countOfAsteriodPerDay.count).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i+1) , y: Double(countOfAsteriodPerDay[i]))
        }
        var set1: BarChartDataSet! = nil
        if let set = neoBarChatView.data?.first as? BarChartDataSet {
            set1 = set
            set1.replaceEntries(yVals)
            neoBarChatView.data?.notifyDataChanged()
            neoBarChatView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "Graph b/w Day 1 to 7 & Count of Asteriods")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            neoBarChatView.data = data
        }
        
    }
    
    func errorAlert(errorDescr : String) {
        let alert = UIAlertController(title: "Error?", message: errorDescr,         preferredStyle: UIAlertController.Style.alert)
     
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                                            //Sign out action
            }))
            self.present(alert, animated: true, completion: nil)
        }
}

