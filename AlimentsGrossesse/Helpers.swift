//
//  Helpers.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import Foundation

func sanitizeSearchText(searchText: String) -> String {
    return searchText.lowercaseString.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
}
