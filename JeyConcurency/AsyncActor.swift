//
//  AsyncActor.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/22/23.
//

import SwiftUI
import Foundation
import UIKit

//stack vs heap
//class vs struct vs actor
// struct vs classes - structs are faster and better than classes because copying is safer than passing multiple reference ,
// actor
// nonisolated
// global actor

struct AsyncActor: View {
    var body: some View {
        Text("Actorvsstruct")
            .onAppear {
                runTest()
            }
    }
    
    func runTest() {
        structtest()
        classtest()
        actortest()
    }
    
    
    // pass by value
    
    //Value types example - int, struct, enum, string, Tuple, array, dictionary
    
    // uses stack memory
    
    func structtest() {
        let objA = Library(book: "davinci")
      
        var objB = objA
        objB.book = "Great Book"
        
        print(objA.book)
        print(objB.book)
    }
    
    // pass by reference types
    
    // heap memory (both objects are using the same pointer)
    func classtest() {
        let objA = ClassLibrary(book: "indiana jones")
        let objB = objA
        objB.book = "harry potter"
        print(objA.book)
        print(objB.book)
    }
    
    func actortest() {
        Task {
            let objA = MyActorDataManager(book: "marvel")
            let objB = objA
            await objB.updateTitle(value: "john wick")
            
            await print(objA.book)
            await print(objB.book)
            
            let objc = GlobalDatabase.instance
            let result = await objc.randomData()
            print(result ?? "")
            
            let nonisolated = objc.getSaveData()
            print(nonisolated)
            
            let runGlobalActor = await objc.runGlobalActor()
            print(runGlobalActor)
            
        }
    }
}



struct Library {
    var book: String
}

class ClassLibrary {
    var book: String
    
    init(book: String) {
        self.book = book
    }
}

/*
 
Why actor ?
 
 Actors are thread safe, IF two thread access the same object it may crash , dataraces etc
 
 Both classes and actors are stored in heap memory
 
 */


actor MyActorDataManager {
    var book: String
    
    init(book: String) {
        self.book = book
    }
    
    func updateTitle(value: String) {
        self.book = value
    }
    
}

actor MyActorDataManager1 {
      
    init() {}
    
    var data: [String] = []
    
    func randomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    // function not worried about thread safe
   // This function is not isolated to actor
    nonisolated func getSaveData() -> String {
        return "new string"
    }
    
    @GlobalDatabase func runGlobalActor() -> String {
        return "Global actor"
    }
}

@globalActor actor GlobalDatabase {
  static let shared = GlobalDatabase()
  static let instance = MyActorDataManager1()
}

#Preview {
    AsyncActor()
}


// when to use what?

// Structs are best for data modal and views
// classes are best for viewmodels in observable object
// Actors are best for data manager or data store classes like example: getDataFromDatabase()



