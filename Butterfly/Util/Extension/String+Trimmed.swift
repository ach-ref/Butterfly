//
//  String+Trimmed.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import Foundation

extension String {
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
