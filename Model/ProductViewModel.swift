//
//  ProductViewModel.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//


import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import QuickLookThumbnailing

struct Product: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var price: Double
    var description: String
    var imageURL: String
    var modelURL: String
    var modelThumbnail: String
    var room: String
    var category: String
    var height: Double
    var depth: Double
    var width: Double
}

class ProductViewModel: ObservableObject {
    @Published var product: Product?
    @Published var products: [Product] = []
    @Published var categoryProducts: [Product] = []
    
    var chairs: [Product] {
        products.filter { $0.category.contains("chair") }
    }
    var tables: [Product] {
        products.filter { $0.category.contains("table") }
    }
    var beds: [Product] {
        products.filter { $0.category.contains("bed") }
    }
    var storages: [Product] {
        products.filter { $0.category.contains("storage") }
    }
    
    private var db = DataController.shared.db
    private var storage = DataController.shared.storage
    
    func getProduct(id: String, completion: @escaping (Product) -> Void = { _ in }) {
        db.collection("furnitures").document(id).getDocument { snapshot, error in
            if let error = error {
                print("Error getting product: \(error.localizedDescription)")
            } else if let snapshot = snapshot, snapshot.exists {
                do {
                    let product = try snapshot.data(as: Product.self)
                    DispatchQueue.main.async {
                        self.product = product
                    }
                    completion(product)
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                }
            } else {
                print("Product document does not exist")
            }
        }
    } // getProduct
    
    func getAllProducts() {
        db.collection("furnitures").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting product: \(error.localizedDescription)")
            } else {
                // Iterate through each document in the collection
                for document in snapshot!.documents {
                    // Try to decode document data into Product model
                    do {
                        let product = try document.data(as: Product.self)
                        // Append the decoded product to the products array
                        DispatchQueue.main.async {
                            self.products.append(product)
                        }
                    } catch {
                        print("Error decoding product: \(error.localizedDescription)")
                    }
                }
            }
        }
    } // getAllProduct
    
    func getProductsByCategory(for category: String){
        db.collection("furnitures").whereField("category", isEqualTo: category).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting product: \(error.localizedDescription)")
            } else {
                // Clear the existing products array
                self.categoryProducts.removeAll()
                
                // Iterate through each document in the collection
                for document in snapshot!.documents {
                    // Try to decode document data into Product model
                    do {
                        let product = try document.data(as: Product.self)
                        // Append the decoded product to the products array
                        DispatchQueue.main.async {
                            self.categoryProducts.append(product)
                        }
                    } catch {
                        print("Error decoding product: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Function to upload image to Firebase Storage and update imageURL
    func uploadImageToStorage(imageData: Data, completion: @escaping (String?) -> Void) {
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        
        // Upload the image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata, error == nil else {
                print("Error uploading image: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    completion(url.absoluteString)
                }
            }
        }
    }
    
    func saveProduct(product: Product, imageData: Data?, completion: @escaping (Bool) -> Void) {
        if let imageData = imageData {
            // If image data is provided, upload the image to Firebase Storage
            uploadImageToStorage(imageData: imageData) { imageURL in
                if let imageURL = imageURL {
                    var newProduct = product
                    //                    newProduct.imageURL = imageURL
                    self.saveProductToFirestore(product: newProduct, completion: completion)
                } else {
                    completion(false)
                }
            }
        } else {
            // If no image data is provided, save the product directly to Firestore
            saveProductToFirestore(product: product, completion: completion)
        }
    }
    
    private func saveProductToFirestore(product: Product, completion: @escaping (Bool) -> Void) {
        do {
            let _ = try db.collection("furnitures").addDocument(from: product) { error in
                if let error = error {
                    print("Error adding product to Firestore: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("Error encoding product: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Download model file to local path
    func downloadModelFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let downloadedUrl = downloadedUrl else {
                completion(.failure(NSError(domain: "Downloaded URL is nil", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let localFileUrl = documentsDirectory.appendingPathComponent("\(UUID()).usdz")
                
                if FileManager.default.fileExists(atPath: localFileUrl.path) {
                    try FileManager.default.removeItem(at: localFileUrl)
                }
                
                try FileManager.default.moveItem(at: downloadedUrl, to: localFileUrl)
                
                DispatchQueue.main.async {
                    completion(.success(localFileUrl))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func downloadModelFileAsync(from url: URL) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Invalid response status code", code: 0, userInfo: nil)
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localFileUrl = documentsDirectory.appendingPathComponent("\(UUID()).usdz")
        
        if FileManager.default.fileExists(atPath: localFileUrl.path) {
            try FileManager.default.removeItem(at: localFileUrl)
        }
        
        try data.write(to: localFileUrl)
        
        return localFileUrl
    }
    
    /// Generate Thumbnail : 1:24:35
    func productThumbnail(modelURL:URL) async -> UIImage?{
                do {
                    let localModelURL = try await downloadModelFileAsync(from: modelURL)
                    print(localModelURL)
                    // Use the localModelURL
                    let thumbnailRequest = await QLThumbnailGenerator.Request(fileAt: localModelURL, size: .init(width: 50, height: 50), scale: UIScreen.main.scale, representationTypes: .all)
                    print("Generating")
                    let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: thumbnailRequest)
                    print("Generated")
                        return thumbnail.uiImage
                } catch {
                    print("Error downloading model file: \(error.localizedDescription)")
                }
        return nil
    }
}

class DataController: ObservableObject {
    static let shared = DataController()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    private init() {}
}

