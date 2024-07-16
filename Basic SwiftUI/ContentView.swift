//
//  ContentView.swift
//  Basic SwiftUI
//
//  Created by Amilzith on 17/07/24.
//

import SwiftUI
enum BottomBarSelectedTab:Int{
    case home = 1
    case bookmark = 2
}

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var isPresent = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.white)
    }
    
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView().tabItem {
                    BottomBarIconView(image: "house", text: "Home", isActive: selectedTab == BottomBarSelectedTab.home.rawValue)
                }.tag(1)
                BookmarkView().tabItem {
                    BottomBarIconView(image: "bookmark", text: "Home", isActive: selectedTab == BottomBarSelectedTab.bookmark.rawValue)
                }.tag(1)
            }
            .accentColor(Color.blue)
            .onChange(of: selectedTab, perform: { newTap in
                self.selectedTab = newTap
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}

struct BottomBarIconView: View {
    
    var image:String
    var text:String
    var isActive:Bool
    
    var body: some View {
        HStack(spacing: 10){
            GeometryReader{
                geo in
                VStack(spacing: 3){
                    Rectangle()
                        .frame(height: 0)
                    Image(systemName: image)
                        .resizable()
                        .frame(width: 24,height: 24)
                        .foregroundColor(isActive ? .blue : .gray)
                    Text(text)
                        .font(.caption)
                        .foregroundColor(isActive ? .blue : .gray)
                }
            }
            
        }
    }
}
