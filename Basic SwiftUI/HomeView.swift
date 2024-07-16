//
//  HomeView.swift
//  Basic SwiftUI
//
//  Created by Amilzith on 17/07/24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    var viewModel = ViewModel()
    @FetchRequest(entity: UserDataEntity.entity(), sortDescriptors: [], animation: .default)
    var users: FetchedResults<UserDataEntity>
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Button {
                        viewModel.deleteLastObj(users: users)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color.gray)
                            .frame(width: 25,height: 25)
                            
                    }
                    Button {
                        viewModel.removeAll(users: users)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color.gray)
                            .frame(width: 25,height: 25)
                            
                    }
                    Button {
                        fetchFirstUser(withId: users.first?.id ?? 0)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color.gray)
                            .frame(width: 25,height: 25)
                            
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible())]){
                    ForEach(Array(users.enumerated()), id: \.element) { index, item in
                        Text(item.name ?? "")
                        Text("\(item.id)")
                        Text(item.email ?? "")
                        Text(item.avatar ?? "")
                    }
                }
            }
        }
    }
    
    func fetchFirstUser(withId id: Int16) {
        let fetchedUser = viewModel.getFirst(withId: id, users: users)
        print(fetchedUser)
    }
    
}

#Preview {
    ContentView()
}


class ViewModel: ObservableObject {
    
    init() {
        callApi()
    }
    
    func callApi() {
        Task {
            let data = try await fetchData()
            saveDataContext(users: data?.data ?? [])
        }
    }
    
    func saveDataContext(users: [User]) {
        let context = PersistenContainer.shared.container.viewContext
        
        for user in users {
            let nsFetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
            nsFetchRequest.predicate = NSPredicate(format: "id == %d", user.id ?? 0)
            
            do {
                let availableUser = try context.fetch(nsFetchRequest)
                if let userDataEntity = availableUser.first {
                    userDataEntity.name = (user.firstName ?? "") + " " + (user.lastName ?? "")
                    userDataEntity.email = user.email ?? ""
                    userDataEntity.avatar = user.avatar ?? ""
                } else {
                    let userDataEntity = UserDataEntity(context: context)
                    userDataEntity.name = (user.firstName ?? "") + " " + (user.lastName ?? "")
                    userDataEntity.email = user.email ?? ""
                    userDataEntity.avatar = user.avatar ?? ""
                    userDataEntity.id = Int16(user.id ?? 0)
                }
            } catch {
                print("Error 2")
            }
            
            do {
                try context.save()
            } catch {
                print("Error 3")
            }
        }
    }
    
    func deleteLastObj(users: FetchedResults<UserDataEntity>) {
        let context = PersistenContainer.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserDataEntity> = UserDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", users.last?.id ?? 0)
        
        do {
            var users = try context.fetch(fetchRequest)
            
            guard let lastUser = users.first else {
                print("No users found to delete.")
                return
            }
            
            context.delete(lastUser)
            try context.save()
            
            print("Deleted last user: \(lastUser.name ?? "")")
        } catch {
            print("Error fetching or deleting last user:", error)
        }
    }
    
    func removeAll(users: FetchedResults<UserDataEntity>) {
        let context = PersistenContainer.shared.container.viewContext
        for user in users {
            context.delete(user)
        }
        
        do {
            try context.save()
            print("All users deleted successfully.")
        } catch {
            print("Error saving context after deletion:", error)
        }
    }
    
    func getFirst(withId id: Int16, users: FetchedResults<UserDataEntity>) -> UserDataEntity? {
        return users.first(where: { $0.id == id })
    }
    
    func fetchData() async throws -> ResponseModel?  {
        guard let url = URL(string: "https://reqres.in/api/users?page=2") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let jsonDecoder = JSONDecoder()
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let jsonData = try? JSONSerialization.jsonObject(with: data) {
            print(jsonData)
        }
        
        return try jsonDecoder.decode(ResponseModel.self, from: data)
    }
}

struct ResponseModel: Decodable, Hashable {
    let data: [User]?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct User: Decodable, Hashable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let id: Int?
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case id = "id"
        case avatar = "avatar"
        
    }
}

