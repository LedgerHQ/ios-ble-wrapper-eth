//
//  ButtonView.swift
//  EthereumWrapperDemo
//
//  Created by Harrison Friia on 6/30/23.
//

import SwiftUI

struct ButtonView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 10)
                .cornerRadius(10)
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ButtonView(title: "title1", action: {})
            ButtonView(title: "title2", action: {})
            ButtonView(title: "title3", action: {})
        }
        .background(.black)
    }
}
