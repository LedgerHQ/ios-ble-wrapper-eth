//
//  ContentView.swift
//  EthereumWrapperDemo
//
//  Created by Harrison Friia on 6/30/23.
//

import BleTransport
import SwiftUI

struct ContentView: View {
    @StateObject private var logManager = LogManager()
    @StateObject private var deviceManager = DeviceManager()

    let primaryBackground = Color(red: 19 / 255, green: 20 / 255, blue: 21 / 255)
    let secondaryBackground = Color(red: 28 / 255, green: 29 / 255, blue: 31 / 255)
    let logText = Color(white: 230 / 255)

    var body: some View {
        VStack {
            Spacer()

            GroupBox {
                VStack(alignment: .leading) {
                    ButtonView(title: "Connect", action: deviceManager.create)
                    ButtonView(title: "Sign Transaction", action: deviceManager.signTransaction)
                    ButtonView(title: "Get App Configuration", action: deviceManager.getAppConfiguration)
                    ButtonView(title: "Get Address", action: deviceManager.getAddress)
                    ButtonView(title: "Open App", action: deviceManager.openApp)
                }
            }
            .backgroundStyle(secondaryBackground)

            HStack {
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(spacing: 0) {
                            ForEach(logManager.logs.indices, id: \.self) { index in
                                Text(logManager.logs[index])
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(logText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(5)
                                    .background(index % 2 == 0 ? secondaryBackground : primaryBackground)
                                    .id(index)
                                    .cornerRadius(6)
                                    .delayedAnimation()
                            }
                            .onChange(of: logManager.logs.count) { _ in
                                scrollView.scrollTo(logManager.logs.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
                .textSelection(.enabled)
                .padding(5)
                .background(secondaryBackground)
                .cornerRadius(6)
            }
            .frame(minHeight: 200, maxHeight: .infinity)
        }
        .padding()
        .background(primaryBackground)
        .onAppear(perform: {
            deviceManager.logManager = logManager
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
