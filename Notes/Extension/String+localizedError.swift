//
//  String+localizedError.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 16/11/2022.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
