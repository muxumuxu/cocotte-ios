//
//  Helpers.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import Foundation

func sanitizeSearchText(_ searchText: String) -> String {
    return searchText.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current)
}
