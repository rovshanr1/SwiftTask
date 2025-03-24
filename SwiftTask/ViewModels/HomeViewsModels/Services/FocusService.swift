import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth

class FocusService {
    static let shared = FocusService()
    private let db = Firestore.firestore()
    private let context = PersistenceController.shared.container.viewContext
    
    // MARK: - CoreData Operations
    
    func saveFocusSession(_ focus: DailyFocus) {
        let fetchRequest: NSFetchRequest<FocusEntity> = FocusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", focus.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                existingEntity.update(duration: focus.duration)
            } else {
                _ = FocusEntity.create(
                    in: context,
                    id: focus.id,
                    date: focus.date,
                    duration: focus.duration,
                    userId: focus.userId
                )
            }
            
            try context.save()
            syncFocusToFirebase(focus)
        } catch {
            print("CoreData kaydetme hatası: \(error)")
        }
    }
    
    func loadFocusSessions() -> [DailyFocus] {
        let fetchRequest: NSFetchRequest<FocusEntity> = FocusEntity.fetchRequest()
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { DailyFocus(from: $0) }
        } catch {
            print("CoreData yükleme hatası: \(error)")
            return []
        }
    }
    
    // MARK: - Firebase Operations
    
    func syncFocusToFirebase(_ focus: DailyFocus) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let focusRef = db.collection("users").document(userId).collection("focus").document(focus.id)
        
        focusRef.setData(focus.asDictionary) { error in
            if let error = error {
                print("Firebase senkronizasyon hatası: \(error)")
                OfflineSyncManager.shared.addPendingOperation(
                    .init(type: .add, taskId: focus.id, taskData: focus.asDictionary)
                )
            }
        }
    }
    
    func loadFocusFromFirebase(completion: @escaping ([DailyFocus]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let focusRef = db.collection("users").document(userId).collection("focus")
        
        focusRef.getDocuments { snapshot, error in
            if let error = error {
                print("Firebase yükleme hatası: \(error)")
                completion([])
                return
            }
            
            let focusSessions = snapshot?.documents.compactMap { document in
                DailyFocus(from: document.data())
            } ?? []
            
            completion(focusSessions)
        }
    }
    
    // MARK: - Sync Operations
    
    func syncLocalToFirebase() {
        let localSessions = loadFocusSessions()
        localSessions.forEach { syncFocusToFirebase($0) }
    }
    
    func syncFirebaseToLocal(completion: @escaping () -> Void) {
        loadFocusFromFirebase { remoteSessions in
            remoteSessions.forEach { self.saveFocusSession($0) }
            completion()
        }
    }
} 