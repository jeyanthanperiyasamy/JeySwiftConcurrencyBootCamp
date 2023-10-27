//
//  AsyncThread.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/21/23.
//

import SwiftUI
import Foundation

// this is to explain async await
// task
class AsyncThreadViewModal: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addData(value: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("thread \(value): \(Thread.current)")
        }
    }
    
    func addDataWorkerThread(value: String) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let foo = "thread \(value): \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append("thread \(foo)")
            }
        }
    }
    
    func addDataAsync() async {
        let value1 = "value1: \(Thread.current)"
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        let value2 = "value2: \(Thread.current)"
        await MainActor.run {
            let value3 = "value3: \(Thread.current)"
            self.dataArray.append(value1)
            self.dataArray.append(value2)
            self.dataArray.append(value3)
        }
    }
}

struct CancellableView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click Here") {
                    AsyncThread()
                }
            }
        }
    }
}

struct AsyncThread: View {
    
    @StateObject private var modal = AsyncThreadViewModal()
    @State private var listTask: Task<(), Never>? = nil
    
    var body: some View {
        List {
            ForEach(modal.dataArray, id:\.self) { data in
                Text(data)
            }
        }
        .onDisappear {
            listTask?.cancel()
        }
        .onAppear {
            modal.addData(value: "First Data")
            modal.addData(value: "second Data")
            modal.addDataWorkerThread(value: "third Data")
            
            Task(priority: .high) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
            }
            Task(priority: .medium) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
            }
            
            Task(priority: .userInitiated) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
            }
            
            Task(priority: .utility) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
            }
            
            Task(priority: .background) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
            }
            
            Task(priority: .low) {
                print("\(Thread.current), \(Task.currentPriority.rawValue)")
                
                // await modal.addDataAsync()
                // await Task.yield() // used to finish the other task and continue this later
                //                Task.detached {
                //                    await modal.addDataAsync()
                //                }
            }
        }
    }
}

/*    func cancelTask() {
 //        for x in array {
 //            // perirodcally check for cancellation
 //
 //           // Task.checkCancellation()
 //           // Task.isCancelled
 //        }
 //    }
 */

#Preview {
    CancellableView()
}
