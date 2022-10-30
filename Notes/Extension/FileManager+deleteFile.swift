//
//  FileManager+deleteFile.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 03/09/2022.
//

import Foundation

extension FileManager {

    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func deleteFile(_ fileName: String) -> Bool {
        let manager = FileManager.default
        let file = getDocumentsDirectory().appendingPathComponent(fileName).path

        do {
            if !manager.fileExists(atPath: file) {
                print("FileManager.deleteFile - trying to delete a file which does not exists : \(fileName)")
                return true
            }

            if !manager.isDeletableFile(atPath: file) {
                print("FileManager.deleteFile - trying to delete a file which is not deletable : \(fileName)")
                return false
            }

            try manager.removeItem(atPath: file)

            // double check
            return !manager.fileExists(atPath: file)
        } catch {
            print("FileManager.deleteFile - Failed to delete file : \(fileName), \(error.localizedDescription)")

            return !manager.fileExists(atPath: file)
        }
    }
}
