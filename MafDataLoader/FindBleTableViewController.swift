//
//  FindBleTableViewController.swift
//  MafDataLoader
//
//  Created by Mihail Trosinenco on 21.10.2021.
//

import UIKit
import CoreBluetooth
import OSLog

class FindBleTableViewController: UITableViewController, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var startSearchBluetoothDevicesButton: UIBarButtonItem!
    private var observer: NSObjectProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        self.navigationController?.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("NewBlePeripheralDiscovered"), object: nil, queue: nil, using: addDiscoveredPeripheralNameToTableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observer!)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return BleManager.Ble.getPeripheralsCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothInfoCell", for: indexPath)

        // Configure the cell...
        if let peripheral = BleManager.Ble.getPeripheral(index: indexPath.row) {
            cell.textLabel?.text = peripheral.name
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !BleManager.Ble.setSelectedPeripheral(index: indexPath.row) {
            let alert = UIAlertController(title: "MafDataLoader", message: "Ble peripheral selection error.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let _ = viewController as? ViewController {
            BleManager.Ble.stopBleScan()
        }
    }

    // MARK: Actions
    @IBAction func startSearchBluetoothDevices(_ sender: UIBarButtonItem) {
        if sender.title == "Search" {
            if BleManager.Ble.centralManagerState == .poweredOn {
                sender.title = "Stop"
                BleManager.Ble.removeAllPeripherals()
                BleManager.Ble.startBleScan()
                tableView.reloadData()
            }
            else {
                var alertStr: String
                
                switch(BleManager.Ble.centralManagerState) {
                case .poweredOff:
                    alertStr = "Bluetooth is powered off."
                case .resetting:
                    alertStr = "Bluetooth is resetting."
                case .unauthorized:
                    alertStr = "Bluetooth is unauthorized."
                case .unsupported:
                    alertStr = "Bluetooth is unsupported."
                default:
                    alertStr = "Bluetooth unkown error."
                }
                
                let alert = UIAlertController(title: "MafDataLoader", message: alertStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            BleManager.Ble.stopBleScan()
            sender.title = "Search"
        }
    }
    
    //MARK: Private Methods
    private func addDiscoveredPeripheralNameToTableView(notification: Notification) {
        let indexPath = IndexPath(row: BleManager.Ble.getPeripheralsCount() - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}
