//
//  Supabase.swift
//  Harbor
//
//  Created by Bernardo Santiago Marin on 14/03/26.
//


import Foundation
import Supabase

class SupabaseInstance {
    static let shared: SupabaseInstance = .init()
    
    let supabase: SupabaseClient
    
    private init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://ovansukuzlzxmhjbtnid.supabase.co")!,
            supabaseKey: "sb_publishable_x-wMtwuWTXU4erBci-eE-g__CvYvyiD"
        )
    }
}
        
