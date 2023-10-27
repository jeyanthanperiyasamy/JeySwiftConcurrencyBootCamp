//
//  AsyncSendable.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/22/23.
//

import SwiftUI

actor CurrentUserManager {
    
    @Published var myData: [Userinfo] = []
    
    func updateDB(userinfo: Userinfo) async {
        myData.append(userinfo)
    }
}

// value type and thread safe
// this is helping compiler to make sure this is thread safe
struct Userinfo: Sendable {
    let name: String
}

// Reference type and classes are not thread safe

final class MyUserinfo: @unchecked Sendable {
    var name: String
    
    let lock = DispatchQueue(label: "com.serial.queue")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        lock.async {
            self.name = name
        }
    }
}

class SendableViewModal: ObservableObject {
    let manager = CurrentUserManager()

    @Published var dataArray: [Userinfo] = []
    
    init() {
        getDB()
    }
    
    func updateDB() async {
         await manager.updateDB(userinfo: Userinfo(name: "jey") )
         await manager.updateDB(userinfo: Userinfo(name: "jey1") )
    }
    
    func getDB() {
        Task {
            for await value in await manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
    }
}

struct AsyncSendable: View {
    let viewmodel = SendableViewModal()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewmodel.dataArray, id: \.self) {
                    Text($0.name).font(.headline)
                }
            }
        }
        .task {
            await viewmodel.updateDB()
        }
    }
}

#Preview {
    AsyncSendable()
}
