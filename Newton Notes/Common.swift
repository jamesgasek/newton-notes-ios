//
//  components.swift
//  Newton Notes
//
//  Created by James Gasek on 11/6/24.
//
import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        Button(action: {

            configuration.isOn.toggle()

        }, label: {
            HStack {
                configuration.label
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")

            }
        })
    }
}
