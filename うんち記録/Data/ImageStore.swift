//
//  ImageStore.swift
//  うんち記録
//
//  記録用画像の保存・読み込み
//

import Foundation
import SwiftUI
import UIKit

enum ImageStore {
    private static let directoryName = "RecordImages"
    
    private static var directoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(directoryName)
    }
    
    static func save(_ image: UIImage) -> String? {
        let id = UUID().uuidString
        let fileURL = directoryURL.appendingPathComponent("\(id).jpg")
        
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            try data.write(to: fileURL)
            return "\(id).jpg"
        } catch {
            return nil
        }
    }
    
    static func load(id: String) -> UIImage? {
        let fileURL = directoryURL.appendingPathComponent(id)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    static func delete(id: String) {
        let fileURL = directoryURL.appendingPathComponent(id)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    static func deleteAll(ids: [String]) {
        for id in ids {
            delete(id: id)
        }
    }
}
