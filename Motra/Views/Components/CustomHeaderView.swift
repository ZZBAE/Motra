//
//  CustomHeaderView.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/10/25.
//

import SwiftUI

struct CustomHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    VStack {
        CustomHeaderView(title: "Motra")
        Spacer()
    }
}
