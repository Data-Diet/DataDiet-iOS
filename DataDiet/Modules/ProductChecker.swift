//
//  ImageSetter.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 11/20/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import Foundation

struct ProductChecker {
    
    func findAllergens(Ingredients: [String], Allergens: [String]) -> [String] {
        var foundAllergens = [String]()
        
        for ingredient in Ingredients {
            for allergen in Allergens {
                if ingredient.lowercased().contains(allergen.lowercased()) {
                    foundAllergens.append(ingredient)
                }
            }
        }
        return foundAllergens
        
    }
    
}

