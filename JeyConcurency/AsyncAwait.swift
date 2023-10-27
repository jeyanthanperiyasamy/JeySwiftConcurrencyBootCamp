//
//  TryCatchBootcamp.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/20/23.
//

import SwiftUI
import Foundation
import Combine

// Download images with completionhandler, Async/Await and Combine
// Dataloader, manager, downloader, domainmodal,  or Datastorage class

class AsyncAwaitModalLoader {
    
    let url = URL(string: "https://placedog.net/400/300")!
    
    // drawback: passing an optional image if ok, but the caller has to figure out how to use that
    func handleRespone(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func download(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleRespone(data: data, response: response)
            completionHandler(image, error)
        }.resume()
    }
    
    func downloadCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for:url)
            .map(handleRespone)
            .mapError( { $0 } )
            .eraseToAnyPublisher()
    }
    
    func downloadAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await  URLSession.shared.data(from: url, delegate: nil)
            let image = handleRespone(data: data, response: response)
            return image
        }
        catch {
            throw error
        }
    }
}


class AsyncAwaitViewModal: ObservableObject {
    @Published var text: String = "initalDat"
    
    @Published var image: UIImage? = nil
    
    let manager = AsyncAwaitModalLoader()
    var cancellables = Set<AnyCancellable>()
    
    func getImage() {
        manager.download { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func getImageCombine() {
        manager.downloadCombine()
            .receive(on: DispatchQueue.main)
            .sink { val in
                
            } receiveValue: { [weak self] image in
                self?.image = image
                
            }.store(in: &cancellables)
        }
    
    func getImageasync() async {
       let image = try? await manager.downloadAsync()
        await MainActor.run {
            self.image = image
        }
    }
    
}

struct AsyncAwait: View {
    
    @StateObject private var viewmodel = AsyncAwaitViewModal()
    
    var body: some View {
        ZStack(alignment: .leading) {
            if let image = viewmodel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            
            Text("Hello")
                .font(.largeTitle)
                .background(.blue)
                .foregroundStyle(.white)
        }
        
        .onAppear {
             viewmodel.getImage()
          //  viewmodel.getImageCombine()
//            Task {
//                await viewmodel.getImageasync()
//            }
        }
    }
}

#Preview {
    AsyncAwait()
}
