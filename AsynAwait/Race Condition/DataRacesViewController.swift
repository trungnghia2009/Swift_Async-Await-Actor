//
//  DataRacesViewController.swift
//  AsynAwait
//
//  Created by trungnghia on 12/03/2023.
//

///https://swiftsenpai.com/swift/actor-prevent-data-race/

/*
 Xcode has a "Thread Sanitizer" that helps developers to detect data races in a more consistent manner.
 - You can enable it by navigating to Product > Scheme > Edit Scheme…
 - After that, in the edit scheme dialog choose Run > Diagnostic > check the Thread Sanitizer checkbox.
 */

import UIKit

class DataRacesViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var CountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Use Actor to prevent Data Races"
    }
    
    
    /// Function to make data races issue
    func triggerCount1() {
        let totalCount = 1000
        let counter = Counter()
        let group = DispatchGroup()

        // Call `addCount()` asynchronously 1000 times
        for _ in 0..<totalCount {
            
            DispatchQueue.global().async(group: group) {
                counter.addCount()
            }
        }

        group.notify(queue: .main) {
            // Dispatch group completed execution
            // Show `count` value on label
            self.statusLabel.text = "\(counter.count)"
        }
    }
    
    /// Using serial queue to fix data races issue
    func triggerCount2() {
        let totalCount = 1000
        let counter = Counter()
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "Serial queue")

        // Call `addCount()` asynchronously 1000 times
        for _ in 0..<totalCount {
            
            serialQueue.async(group: group) {
                counter.addCount()
            }
        }

        group.notify(queue: .main) {
            // Dispatch group completed execution
            // Show `count` value on label
            self.statusLabel.text = "\(counter.count)"
        }
    }
    
    /// Get the right value but still get data races
    func triggerCount3() {
        let totalCount = 1000
        let counter = Counter()

        // Create a parent task
        Task {
            
            // Create a task group
            await withTaskGroup(of: Void.self, body: { taskGroup in
                
                for _ in 0..<totalCount {
                    // Create child task
                    taskGroup.addTask {
                        counter.addCount()
                    }
                }
            })
            
            statusLabel.text = "\(counter.count)"
        }
    }
    
    /// Using actor to fix data races
    func triggerCount4() {
        let totalCount = 1000
        let counter = NewCounter()

        // Create a parent task
        Task {
            
            // Create a task group
            await withTaskGroup(of: Void.self, body: { taskGroup in
                
                for _ in 0..<totalCount {
                    // Create child task (write count)
                    taskGroup.addTask {
                        await counter.addCount()
                    }
                }
            })
            
            // Read count
            statusLabel.text = "\(await counter.count)"
        }
    }
    
    @IBAction func didTap(_ sender: Any) {
//        triggerCount1()
//        triggerCount2()
//        triggerCount3()
        triggerCount4()
    }
}
