//
//  ViewController.swift
//  MafDataLoader
//
//  Created by Mihail Trosinenco on 21.10.2021.
//

import UIKit
import CoreBluetooth
import OSLog
import Charts
import Foundation
import CoreGraphics

class ViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var mafDataConnectButton: UIButton!
    @IBOutlet weak var mafDataReadButton: UIButton!
    @IBOutlet weak var mafDataWriteButton: UIButton!
//    @IBOutlet weak var mafDataText: UITextView!
//    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lineChart: MyNewLineChart!
    
    
    private var observer: NSObjectProtocol!
    
    let yValues: [ChartDataEntry] = [
                    ChartDataEntry(x: 0, y: 1),
                    ChartDataEntry(x: 1, y: 2),
                    ChartDataEntry(x: 2, y: 3),
                    ChartDataEntry(x: 3, y: 4)]
    
    var lineChartDataSet: LineChartDataSet!
    var lineChartData: LineChartData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let dataEntries = generateRandomEntries()
        lineChart.dataEntries = dataEntries
        lineChart.isCurved = true
        
/* //       let pan = UIPanGestureRecognizer(target: self, action: #selector(lineChartGestureRecognizer))
 //       lineChartView.addGestureRecognizer(pan)
     //   lineChartView.delegate = self
        
        
        lineChartDataSet = LineChartDataSet(entries: yValues, label: "mafData")
        
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.setColor(.systemBlue)
        lineChartDataSet.highlightColor = .systemRed
        lineChartDataSet.valueFormatter = LineChartDataSetValueFormatter()
        lineChartDataSet.valueFont = .boldSystemFont(ofSize: 12)
        
        lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = false
        
        lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.leftAxis.labelPosition = .outsideChart
     //   lineChartView.leftAxis.spaceBottom = CGFloat(0)
     //   lineChartView.leftAxis.valueFormatter = LineChartViewAxisValueFormatter()
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.setLabelCount(xAxisLabelCountCalc(count: yValues.count), force: true)
     //   lineChartView.xAxis.valueFormatter = LineChartViewAxisValueFormatter()
        lineChartView.dragEnabled = true
        
        lineChartView.animate(xAxisDuration: 1.5)*/
    }
    
    private func generateRandomEntries() -> [PointEntry] {
            var result: [PointEntry] = []
            for i in 0..<100 {
                let value = Int(arc4random() % 500)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"
                var date = Date()
                date.addTimeInterval(TimeInterval(24*60*60*i))
                
                result.append(PointEntry(value: value, label: formatter.string(from: date)))
            }
            return result
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: .peripheralNotifications, object: nil, queue: nil, using: peripheralDataNotifications)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if BleManager.Ble.isPeripheralConnected {
            mafDataReadButton.isEnabled = true
            mafDataWriteButton.isEnabled = true
        }
        else {
            mafDataReadButton.isEnabled = false
            mafDataWriteButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observer!)
    }
    
    //MARK: Actions
    @IBAction func mafDataConnect(_ sender: UIButton) {
        if mafDataConnectButton.titleLabel?.text == "Connect" {
            if BleManager.Ble.isPeripheralSelected {
                BleManager.Ble.connectSelectedPeripheral()
            }
            else {
                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is not selected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            BleManager.Ble.disconnectSelectedPeripheral()
            mafDataReadButton.isEnabled = false
            mafDataWriteButton.isEnabled = false
            mafDataConnectButton.setTitle("Connect", for: .normal)
        }
    }
    
    @IBAction func mafDataRead(_ sender: UIButton) {
        BleManager.Ble.peripheralData.removeAll()
  /*      lineChartDataSet.removeAll(keepingCapacity: true)
        lineChartDataSet.append(ChartDataEntry(x: 0, y: 0))
        lineChartData.notifyDataChanged()
        lineChartView.notifyDataSetChanged() */
    }
    
    @IBAction func mafDataWrite(_ sender: UIButton) {
        BleManager.Ble.peripheralWrite(string: "Katea jopa")
    }
    
    //MARK: Line Chart Delegates
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        
        
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        print("Did end panning")
    }
    
 /*   @objc func lineChartGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
      //  print(recognizer.state)
        
        switch recognizer.state {
        case .began:
            print("pann began")
            
            if let marker = self.lineChartView.marker as? MarkerView {
                let location = recognizer.location(in: lineChartView)
            }
        case .changed:
            print("pann changed")
        default:
            print("pann default")
        }
        
    } */
    
    //MARK: Private Methods
    private func peripheralDataNotifications(notification: Notification) {
        if let data = notification.object as? String {
            switch data {
           /* case "NewBleData":
                lineChartDataSet.removeAll(keepingCapacity: false)
                for i in 0..<BleManager.Ble.peripheralData.count {
                    lineChartDataSet.append(ChartDataEntry(x: Double(i), y: Double(BleManager.Ble.peripheralData[i])))
                }
                
                lineChartData.notifyDataChanged()
                lineChartView.notifyDataSetChanged()
                lineChartView.animate(xAxisDuration: 1.5)*/
            case "SelectedBleConnected":
                mafDataConnectButton.setTitle("Disconnect", for: .normal)
                mafDataReadButton.isEnabled = true
                mafDataWriteButton.isEnabled = true
            case "SelectedBleDisconnected":
                mafDataReadButton.isEnabled = false
                mafDataWriteButton.isEnabled = false
                mafDataConnectButton.setTitle("Connect", for: .normal)

                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is disconnected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            default:
                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is not selected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func xAxisLabelCountCalc(count: Int) -> Int {
        
        switch count {
        case 0:
            return 2
        case 1..<10:
            return count
        default:
            if (count % 10) < 5 {
                return 5
            }
            
            return count % 10
        }
    }
}

class LineChartDataSetValueFormatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(Int(value))
    }
}

class LineChartViewAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value))
    }
}
