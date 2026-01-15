//
//  SettingsView.swift
//  PokerPotOdds
//
//  Created by Thomas Rakowski on 15.01.26.
//
import SwiftUI


struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemein") {
                    Text("Einstellungen kommen hier hin.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
