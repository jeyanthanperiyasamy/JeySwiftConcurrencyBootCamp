//
//  AsyncLet.swift
//  JeyConcurency
//
//  Created by jey periyasamy on 10/22/23.
//

import SwiftUI

// async let for concurrent task , task group
struct AsyncLet: View {
    
    let url = URL(string: "https://placedog.net/400/300")!
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @StateObject var viewmodal = TaskGroupViewmodal()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image).resizable().scaledToFit().frame(height: 150)
                    }
                }
            }
            .navigationTitle("jey await let")
        }
            .onAppear {
                Task {
                    do {
                        
                        let image1 = try await viewmodal.getImage()
                        self.images.append(image1)
                        
                        let image2 = try await viewmodal.getImage()
                        self.images.append(image2)
                        
                        
                        async let image3 = try await viewmodal.getImage()
                        async let image4 = try await viewmodal.getImage()
                        let (value1, value2) = await (try image3, try image4)
                        self.images.append(value1)
                        self.images.append(value2)
                        
                    }
                }
                
//                Task {
//                    try await viewmodal.getImages()
//                }
                
            }
    
    }
}


class TaskGroupViewmodal: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupManager()
    
    func getImage() async throws -> UIImage {
        let image = try await manager.getImage()
        return image
    }
    
    func getImages() async throws {
        let image = try await manager.fetchImagesTaskGroup()
        await MainActor.run {
            self.images.append(contentsOf: image)
        }
    }
}

class TaskGroupManager {
    
    let url = URL(string: "https://placedog.net/400/300")!
    
    let urlStrings = ["https://placedog.net/400/300","https://placedog.net/400/300","https://placedog.net/400/300","https://placedog.net/400/300"
    ]
    
    func fetchImagesTaskGroup() async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            
            var images: [UIImage] = []
            
            for urlString in urlStrings {
                group.addTask {
                    try await self.getImage(addedurl: URL(string: urlString)!)
                }
            }
            
            for try await image in group {
                images.append(image)
            }
            return images
            
        }
    }
    
    func getImage(addedurl: URL = URL(string: "https://placedog.net/400/300")!) async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        }
    }
}


#Preview {
    AsyncLet()
}
