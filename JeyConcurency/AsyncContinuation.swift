//
//  AsyncContinuation.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/22/23.
//

import SwiftUI

// this is to convert something which is not async/await to async/await
struct AsyncContinuation: View {
    
    @StateObject private var viewmodel = ContinuationVM()
    
    var body: some View {
        ZStack {
            if let image = viewmodel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }.task {
            await viewmodel.getImage()
        }
    }
}

#Preview {
    AsyncContinuation()
}

class ContinuationVM: ObservableObject {
    @Published var image: UIImage? = nil
    let url = URL(string: "https://placedog.net/400/300")!
    
    let manager = ContinuationManager()
    
    func getImage() async {
       
        do {
            let data = try await manager.getData(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        }
        catch {
            print(error)
        }
    }
}

class ContinuationManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
        catch {
            throw error
        }
    }
    
    func getDataContinuation(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let errorVal = error {
                    continuation.resume(throwing: errorVal)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
        
    }
}
