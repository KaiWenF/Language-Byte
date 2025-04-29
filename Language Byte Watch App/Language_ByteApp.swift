//
//  Language_ByteApp.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen ] on [2/10/2025].
//

import SwiftUI

// Import the MainView
import struct Language_Byte_Watch_App.MainView

@main
struct Language_ByteApp: App {
    var body: some Scene {
           WindowGroup {
            MainView()
           }
       }
   }

   #Preview {
    MainView()
   }
