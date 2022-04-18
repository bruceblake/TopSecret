//
//  GameView.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        LoginCVWrapper()
        
            .navigationBarHidden(true).edgesIgnoringSafeArea(.all)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
