import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let context: NSManagedObjectContext
    
    private init() {
        context = PersistenceController.shared.viewContext
    }
    
    // MARK: - Register or Update User Profile
    func saveUserProfile(userId: String, profile: ProfileModel) {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let results = try context.fetch(request)
            let profileEntity: Profile
            
            if let existingProfile = results.first {
                profileEntity = existingProfile  // Update existing profile
            } else {
                profileEntity = Profile(context: context)  //Create a new profile
                profileEntity.userId = userId
            }
            
            profileEntity.userName = profile.userName
            profileEntity.email = profile.email
            profileEntity.taskLeft = Int16(profile.taskLeft)
            profileEntity.taskDone = Int16(profile.taskDone)
            
            try context.save()
            print("User profile saved/updated successfully")
        } catch {
            print("Failed to save user profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetching User Profile
    func fetchUserProfile(userId: String) -> ProfileModel? {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let profiles = try context.fetch(request)
            if let profileEntity = profiles.first {
                return ProfileModel(
                    userName: profileEntity.userName ?? "No Name",
                    taskLeft: Int(profileEntity.taskLeft),
                    taskDone: Int(profileEntity.taskDone),
                    email: profileEntity.email ?? "",
                    timestamp: profileEntity.timestamp ?? Date() // Accessing timestamp directly
                )
            }
        } catch {
            print("Failed to fetch user profile: \(error.localizedDescription)")
        }
        
        return nil
    }

    // MARK: - Saving Profile Photo
    func saveProfileImage(userId: String, imageData: Data) {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let results = try context.fetch(request)
            let profileEntity: Profile
            
            if let existingProfile = results.first {
                profileEntity = existingProfile  // Update existing record
            } else {
                profileEntity = Profile(context: context) //Create a new record
                profileEntity.userId = userId
            }
            
            profileEntity.profileImage = imageData
            
            try context.save()
            print("Profile image saved successfully")
        } catch {
            print("Failed to save profile image: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Bringing Profile Photo
    func fetchProfileImage(userId: String) -> Data? {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let profiles = try context.fetch(request)
            return profiles.first?.profileImage
        } catch {
            print("Failed to fetch profile image: \(error.localizedDescription)")
            return nil
        }
    }
    // Mark: - Deleting Profile Photos
    func deleteProfileImage(userId: String) {
        let fetchRequest: NSFetchRequest<Profile> = Profile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let profileEntity = results.first {
                profileEntity.profileImage = nil
                try context.save()
                print("Profile image removed successfully")
            } else {
                print("No profile found for the given userId")
            }
        } catch {
            print("Error deleting profile image from CoreData: \(error)")
        }
    }
}
