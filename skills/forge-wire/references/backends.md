# Backend Wiring Reference

Complete wiring code patterns for all 6 data backends, 4 auth backends, and 5 analytics backends supported by forge-wire. Each section shows the exact Swift code needed to replace mock implementations with real backend calls.

---

## Data Backends

### 1. Firebase / Firestore

**Required imports:**

```swift
import FirebaseCore
import FirebaseFirestore
```

**SPM dependency:** `https://github.com/firebase/firebase-ios-sdk` — select `FirebaseFirestore`

**Initialization (app entry point):**

```swift
import FirebaseCore

// In App init() or AppDelegate:
FirebaseApp.configure()
```

**CRUD pattern — before (mock):**

```swift
final class ItemManagerMock: ItemManagerProtocol {
    private var items: [Item] = Item.mockData

    func fetchAll() async throws -> [Item] {
        try await Task.sleep(for: .milliseconds(500))
        return items
    }

    func create(_ item: Item) async throws {
        items.append(item)
    }

    func update(_ item: Item) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }

    func delete(id: String) async throws {
        items.removeAll { $0.id == id }
    }
}
```

**CRUD pattern — after (Firestore):**

```swift
import FirebaseFirestore

final class ItemManagerFirestore: ItemManagerProtocol {
    private let db = Firestore.firestore()
    private let collection = "items"

    func fetchAll() async throws -> [Item] {
        let snapshot = try await db.collection(collection)
            .order(by: "created_at", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Item.self)
        }
    }

    func get(id: String) async throws -> Item? {
        let document = try await db.collection(collection).document(id).getDocument()
        return try? document.data(as: Item.self)
    }

    func create(_ item: Item) async throws {
        try db.collection(collection)
            .document(item.id)
            .setData(from: item)
    }

    func update(_ item: Item) async throws {
        try db.collection(collection)
            .document(item.id)
            .setData(from: item, merge: true)
    }

    func delete(id: String) async throws {
        try await db.collection(collection)
            .document(id)
            .delete()
    }
}
```

**Real-time listener pattern:**

```swift
func observeAll() -> AsyncStream<[Item]> {
    AsyncStream { continuation in
        let listener = db.collection(collection)
            .order(by: "created_at", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    if let error {
                        print("Firestore listener error: \(error.localizedDescription)")
                    }
                    return
                }
                let items = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
                continuation.yield(items)
            }
        continuation.onTermination = { _ in
            listener.remove()
        }
    }
}
```

**Error handling:**

```swift
func handleFirestoreError(_ error: Error) -> AppError {
    let nsError = error as NSError
    switch nsError.code {
    case FirestoreErrorCode.notFound.rawValue:
        return .notFound
    case FirestoreErrorCode.permissionDenied.rawValue:
        return .unauthorized
    case FirestoreErrorCode.unavailable.rawValue:
        return .networkError
    case FirestoreErrorCode.alreadyExists.rawValue:
        return .conflict
    default:
        return .unknown(error.localizedDescription)
    }
}
```

**Offline support:** Firestore has built-in offline persistence enabled by default. Documents are cached locally and synced when connectivity resumes. No additional configuration needed for basic offline support.

**Batch operations:**

```swift
func batchUpdate(_ items: [Item]) async throws {
    let batch = db.batch()
    for item in items {
        let ref = db.collection(collection).document(item.id)
        try batch.setData(from: item, forDocument: ref, merge: true)
    }
    try await batch.commit()
}
```

---

### 2. Supabase

**Required imports:**

```swift
import Supabase
```

**SPM dependency:** `https://github.com/supabase/supabase-swift` — select `Supabase`

**Client initialization:**

```swift
import Supabase

let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: Configuration.supabaseURL)!,
    supabaseKey: Configuration.supabaseAnonKey
)
```

**CRUD pattern — after (Supabase):**

```swift
import Supabase

final class ItemManagerSupabase: ItemManagerProtocol {
    private let client: SupabaseClient
    private let table = "items"

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchAll() async throws -> [Item] {
        try await client.database
            .from(table)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func get(id: String) async throws -> Item? {
        try await client.database
            .from(table)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func create(_ item: Item) async throws {
        try await client.database
            .from(table)
            .insert(item)
            .execute()
    }

    func update(_ item: Item) async throws {
        try await client.database
            .from(table)
            .update(item)
            .eq("id", value: item.id)
            .execute()
    }

    func delete(id: String) async throws {
        try await client.database
            .from(table)
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
```

**Real-time subscription:**

```swift
func observeAll() -> AsyncStream<[Item]> {
    AsyncStream { continuation in
        let channel = client.channel("items-changes")

        let subscription = channel.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: table
        ) { insert in
            // Refetch on change for simplicity
            Task {
                if let items = try? await self.fetchAll() {
                    continuation.yield(items)
                }
            }
        }

        Task {
            await channel.subscribe()
            // Yield initial data
            if let items = try? await self.fetchAll() {
                continuation.yield(items)
            }
        }

        continuation.onTermination = { _ in
            Task { await channel.unsubscribe() }
        }
    }
}
```

**Error handling:**

```swift
func handleSupabaseError(_ error: Error) -> AppError {
    if let postgrestError = error as? PostgrestError {
        switch postgrestError.code {
        case "PGRST116":
            return .notFound
        case "42501":
            return .unauthorized
        default:
            return .unknown(postgrestError.message)
        }
    }
    return .networkError
}
```

**Offline/retry:** Supabase does not have built-in offline persistence. Implement a local cache layer if offline support is needed:

```swift
// Simple cache pattern for offline support
actor LocalCache<T: Codable & Identifiable> {
    private var items: [T] = []
    private let cacheKey: String

    func cache(_ items: [T]) {
        self.items = items
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }

    func getCached() -> [T] {
        if items.isEmpty, let data = UserDefaults.standard.data(forKey: cacheKey) {
            items = (try? JSONDecoder().decode([T].self, from: data)) ?? []
        }
        return items
    }
}
```

---

### 3. REST API

**Required imports:**

```swift
import Foundation
```

**No SPM dependency** — uses Foundation's URLSession.

**Network layer setup:**

```swift
final class APIClient {
    let baseURL: URL
    private var authToken: String?

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    func makeRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil as String?
    ) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw AppError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw AppError.unauthorized
        case 404:
            throw AppError.notFound
        case 409:
            throw AppError.conflict
        case 429:
            throw AppError.rateLimited
        case 500...599:
            throw AppError.serverError
        default:
            throw AppError.unknown("HTTP \(httpResponse.statusCode)")
        }
    }
}
```

**CRUD pattern — after (REST):**

```swift
final class ItemManagerREST: ItemManagerProtocol {
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func fetchAll() async throws -> [Item] {
        let request = try api.makeRequest(path: "/items", method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Item].self, from: data)
    }

    func get(id: String) async throws -> Item? {
        let request = try api.makeRequest(path: "/items/\(id)", method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Item.self, from: data)
    }

    func create(_ item: Item) async throws {
        let request = try api.makeRequest(path: "/items", method: "POST", body: item)
        let (_, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
    }

    func update(_ item: Item) async throws {
        let request = try api.makeRequest(path: "/items/\(item.id)", method: "PUT", body: item)
        let (_, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
    }

    func delete(id: String) async throws {
        let request = try api.makeRequest(path: "/items/\(id)", method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
    }
}
```

**Retry with exponential backoff:**

```swift
func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: Duration = .seconds(1),
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    var delay = initialDelay

    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                let jitter = Duration.milliseconds(Int.random(in: 0...500))
                try await Task.sleep(for: delay + jitter)
                delay *= 2
            }
        }
    }
    throw lastError ?? AppError.unknown("Retry exhausted")
}

// Usage:
func fetchAll() async throws -> [Item] {
    try await withRetry {
        let request = try api.makeRequest(path: "/items", method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)
        return try JSONDecoder().decode([Item].self, from: data)
    }
}
```

**Offline caching with URLCache:**

```swift
// Configure URLSession with caching
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .returnCacheDataElseLoad
configuration.urlCache = URLCache(
    memoryCapacity: 10 * 1024 * 1024,  // 10 MB
    diskCapacity: 50 * 1024 * 1024      // 50 MB
)
let session = URLSession(configuration: configuration)
```

---

### 4. GraphQL

**Required imports:**

```swift
import Foundation
```

**No SPM dependency** — uses Foundation's URLSession. For more advanced GraphQL features (code generation, caching), consider Apollo iOS, but the built-in approach works for most apps.

**GraphQL client setup:**

```swift
final class GraphQLClient {
    let endpoint: URL
    private var authToken: String?

    init(endpoint: URL) {
        self.endpoint = endpoint
    }

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    struct GraphQLRequest: Encodable {
        let query: String
        let variables: [String: AnyCodable]?
    }

    struct GraphQLResponse<T: Decodable>: Decodable {
        let data: T?
        let errors: [GraphQLError]?
    }

    struct GraphQLError: Decodable {
        let message: String
        let locations: [Location]?
        let path: [String]?

        struct Location: Decodable {
            let line: Int
            let column: Int
        }
    }

    func execute<T: Decodable>(
        query: String,
        variables: [String: AnyCodable]? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AppError.serverError
        }

        let gqlResponse = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)

        if let errors = gqlResponse.errors, !errors.isEmpty {
            throw AppError.graphQL(errors.map(\.message).joined(separator: ", "))
        }

        guard let result = gqlResponse.data else {
            throw AppError.noData
        }

        return result
    }
}
```

**CRUD pattern — after (GraphQL):**

```swift
final class ItemManagerGraphQL: ItemManagerProtocol {
    private let client: GraphQLClient

    init(client: GraphQLClient) {
        self.client = client
    }

    // Response types
    struct ItemsResponse: Decodable {
        let items: [Item]
    }

    struct ItemResponse: Decodable {
        let item: Item
    }

    struct CreateItemResponse: Decodable {
        let createItem: Item
    }

    struct UpdateItemResponse: Decodable {
        let updateItem: Item
    }

    struct DeleteItemResponse: Decodable {
        let deleteItem: DeleteResult
        struct DeleteResult: Decodable {
            let id: String
        }
    }

    func fetchAll() async throws -> [Item] {
        let query = """
        query GetItems {
            items(orderBy: { createdAt: DESC }) {
                id
                title
                description
                createdAt
                updatedAt
            }
        }
        """
        let response: ItemsResponse = try await client.execute(query: query)
        return response.items
    }

    func get(id: String) async throws -> Item? {
        let query = """
        query GetItem($id: ID!) {
            item(id: $id) {
                id
                title
                description
                createdAt
                updatedAt
            }
        }
        """
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        let response: ItemResponse = try await client.execute(query: query, variables: variables)
        return response.item
    }

    func create(_ item: Item) async throws {
        let mutation = """
        mutation CreateItem($input: CreateItemInput!) {
            createItem(input: $input) {
                id
                title
                description
                createdAt
            }
        }
        """
        let input: [String: AnyCodable] = [
            "title": AnyCodable(item.title),
            "description": AnyCodable(item.description)
        ]
        let variables: [String: AnyCodable] = ["input": AnyCodable(input)]
        let _: CreateItemResponse = try await client.execute(query: mutation, variables: variables)
    }

    func update(_ item: Item) async throws {
        let mutation = """
        mutation UpdateItem($id: ID!, $input: UpdateItemInput!) {
            updateItem(id: $id, input: $input) {
                id
                title
                description
                updatedAt
            }
        }
        """
        let input: [String: AnyCodable] = [
            "title": AnyCodable(item.title),
            "description": AnyCodable(item.description)
        ]
        let variables: [String: AnyCodable] = [
            "id": AnyCodable(item.id),
            "input": AnyCodable(input)
        ]
        let _: UpdateItemResponse = try await client.execute(query: mutation, variables: variables)
    }

    func delete(id: String) async throws {
        let mutation = """
        mutation DeleteItem($id: ID!) {
            deleteItem(id: $id) {
                id
            }
        }
        """
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        let _: DeleteItemResponse = try await client.execute(query: mutation, variables: variables)
    }
}
```

**Error handling:** Handled in the GraphQLClient via the `errors` array in responses.

**Offline/retry:** Use the same `withRetry` pattern from REST. For offline caching, cache parsed responses locally.

---

### 5. CloudKit

**Required imports:**

```swift
import CloudKit
```

**No SPM dependency** — CloudKit is a system framework.

**Prerequisites:** iCloud capability with CloudKit enabled in Xcode project. Container identifier set in entitlements.

**CRUD pattern — after (CloudKit):**

```swift
import CloudKit

final class ItemManagerCloudKit: ItemManagerProtocol {
    private let container = CKContainer.default()
    private let database: CKDatabase
    private let recordType = "Item"
    private let zone: CKRecordZone

    init(scope: CKDatabase.Scope = .private) {
        switch scope {
        case .private:
            self.database = container.privateCloudDatabase
        case .public:
            self.database = container.publicCloudDatabase
        case .shared:
            self.database = container.sharedCloudDatabase
        @unknown default:
            self.database = container.privateCloudDatabase
        }
        self.zone = CKRecordZone(zoneName: "ItemZone")
    }

    func fetchAll() async throws -> [Item] {
        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let (results, _) = try await database.records(matching: query)
        return results.compactMap { _, result in
            guard case .success(let record) = result else { return nil }
            return Item(from: record)
        }
    }

    func get(id: String) async throws -> Item? {
        let recordID = CKRecord.ID(recordName: id)
        let record = try await database.record(for: recordID)
        return Item(from: record)
    }

    func create(_ item: Item) async throws {
        let record = item.toCKRecord(recordType: recordType)
        try await database.save(record)
    }

    func update(_ item: Item) async throws {
        let recordID = CKRecord.ID(recordName: item.id)
        let record = try await database.record(for: recordID)

        // Update fields
        record["title"] = item.title as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue

        try await database.save(record)
    }

    func delete(id: String) async throws {
        let recordID = CKRecord.ID(recordName: id)
        try await database.deleteRecord(withID: recordID)
    }
}
```

**CKRecord mapping extensions:**

```swift
extension Item {
    init?(from record: CKRecord) {
        guard let title = record["title"] as? String else { return nil }
        self.id = record.recordID.recordName
        self.title = title
        self.createdAt = record["createdAt"] as? Date ?? record.creationDate ?? Date()
    }

    func toCKRecord(recordType: String) -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record["title"] = title as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        return record
    }
}
```

**Error handling:**

```swift
func handleCloudKitError(_ error: Error) -> AppError {
    guard let ckError = error as? CKError else {
        return .unknown(error.localizedDescription)
    }
    switch ckError.code {
    case .notAuthenticated:
        return .unauthorized
    case .unknownItem:
        return .notFound
    case .networkUnavailable, .networkFailure:
        return .networkError
    case .quotaExceeded:
        return .quotaExceeded
    case .serverRecordChanged:
        return .conflict
    case .requestRateLimited:
        if let retryAfter = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
            return .rateLimited(retryAfter: retryAfter)
        }
        return .rateLimited(retryAfter: 30)
    default:
        return .unknown(ckError.localizedDescription)
    }
}
```

**Offline/sync:** CloudKit supports offline operations via CKSyncEngine (iOS 17+):

```swift
// CKSyncEngine setup for automatic sync
let configuration = CKSyncEngine.Configuration(
    database: database,
    stateSerialization: loadSyncState(),
    delegate: self
)
let syncEngine = CKSyncEngine(configuration)
```

---

### 6. SwiftData (Local Only)

**Required imports:**

```swift
import SwiftData
```

**No SPM dependency** — SwiftData is a system framework (iOS 17+).

**Model conversion — before (Codable struct):**

```swift
struct Item: StringIdentifiable, Codable, Sendable {
    let id: String
    let title: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
    }
}
```

**Model conversion — after (SwiftData @Model):**

```swift
import SwiftData

@Model
final class ItemModel {
    @Attribute(.unique) var id: String
    var title: String
    var createdAt: Date

    init(id: String = UUID().uuidString, title: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

// Keep the original struct for the protocol interface
// Add mapping extensions:
extension ItemModel {
    func toItem() -> Item {
        Item(id: id, title: title, createdAt: createdAt)
    }

    convenience init(from item: Item) {
        self.init(id: item.id, title: item.title, createdAt: item.createdAt)
    }
}
```

**CRUD pattern — after (SwiftData):**

```swift
import SwiftData

final class ItemManagerSwiftData: ItemManagerProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Item] {
        let descriptor = FetchDescriptor<ItemModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toItem() }
    }

    func get(id: String) throws -> Item? {
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate { $0.id == id }
        )
        let model = try modelContext.fetch(descriptor).first
        return model?.toItem()
    }

    func create(_ item: Item) throws {
        let model = ItemModel(from: item)
        modelContext.insert(model)
        try modelContext.save()
    }

    func update(_ item: Item) throws {
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate { $0.id == item.id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw AppError.notFound
        }
        model.title = item.title
        try modelContext.save()
    }

    func delete(id: String) throws {
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw AppError.notFound
        }
        modelContext.delete(model)
        try modelContext.save()
    }
}
```

**App entry point setup:**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ItemModel.self])
    }
}
```

**Query in Views (optional — for direct view access):**

```swift
struct ItemListView: View {
    @Query(sort: \ItemModel.createdAt, order: .reverse) var items: [ItemModel]

    var body: some View {
        List(items) { item in
            Text(item.title)
        }
    }
}
```

**Offline support:** SwiftData is inherently offline — all data is stored on device. No network calls, no sync. This is the simplest backend option.

---

## Auth Backends

### 1. Firebase Auth

**Required imports:**

```swift
import FirebaseAuth
```

**SPM dependency:** `FirebaseAuth` from `firebase-ios-sdk`

**Before (mock):**

```swift
final class AuthManagerMock: AuthManagerProtocol {
    var currentUser: AppUser? = AppUser.mock
    var isSignedIn: Bool = true

    func signIn(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        currentUser = .mock
        isSignedIn = true
    }

    func signOut() throws {
        currentUser = nil
        isSignedIn = false
    }
}
```

**After (Firebase Auth):**

```swift
import FirebaseAuth

final class AuthManagerFirebase: AuthManagerProtocol {
    var currentUser: AppUser?
    var isSignedIn: Bool = false

    private var stateListener: AuthStateDidChangeListenerHandle?

    init() {
        stateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }
            if let firebaseUser {
                self.currentUser = self.mapUser(firebaseUser)
                self.isSignedIn = true
            } else {
                self.currentUser = nil
                self.isSignedIn = false
            }
        }
    }

    deinit {
        if let listener = stateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.currentUser = mapUser(result.user)
        self.isSignedIn = true
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.currentUser = mapUser(result.user)
        self.isSignedIn = true
    }

    func signOut() throws {
        try Auth.auth().signOut()
        self.currentUser = nil
        self.isSignedIn = false
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: nil
        )
        let result = try await Auth.auth().signIn(with: credential)
        self.currentUser = mapUser(result.user)
        self.isSignedIn = true
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        let result = try await Auth.auth().signIn(with: credential)
        self.currentUser = mapUser(result.user)
        self.isSignedIn = true
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
        self.currentUser = nil
        self.isSignedIn = false
    }

    private func mapUser(_ firebaseUser: FirebaseAuth.User) -> AppUser {
        AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL
        )
    }
}
```

---

### 2. Supabase Auth

**Required imports:**

```swift
import Supabase
```

**After (Supabase Auth):**

```swift
import Supabase

final class AuthManagerSupabase: AuthManagerProtocol {
    var currentUser: AppUser?
    var isSignedIn: Bool = false

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
        Task { await restoreSession() }
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
        let session = try await client.auth.session
        self.currentUser = mapUser(session.user)
        self.isSignedIn = true
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
        let session = try await client.auth.session
        self.currentUser = mapUser(session.user)
        self.isSignedIn = true
    }

    func signOut() async throws {
        try await client.auth.signOut()
        self.currentUser = nil
        self.isSignedIn = false
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        let session = try await client.auth.session
        self.currentUser = mapUser(session.user)
        self.isSignedIn = true
    }

    func signInWithMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(email: email)
    }

    func deleteAccount() async throws {
        // Requires server-side admin API or Edge Function
        throw AppError.notImplemented("Account deletion requires server-side implementation")
    }

    private func restoreSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = mapUser(session.user)
            self.isSignedIn = true
        } catch {
            self.currentUser = nil
            self.isSignedIn = false
        }
    }

    private func mapUser(_ supabaseUser: Supabase.User) -> AppUser {
        AppUser(
            id: supabaseUser.id.uuidString,
            email: supabaseUser.email,
            displayName: supabaseUser.userMetadata["full_name"]?.stringValue,
            photoURL: supabaseUser.userMetadata["avatar_url"]?.stringValue.flatMap(URL.init(string:))
        )
    }
}
```

---

### 3. Custom JWT

**Required imports:**

```swift
import Foundation
import Security  // for Keychain
```

**After (Custom JWT):**

```swift
final class AuthManagerJWT: AuthManagerProtocol {
    var currentUser: AppUser?
    var isSignedIn: Bool = false

    private let api: APIClient
    private let keychain = KeychainHelper()

    init(api: APIClient) {
        self.api = api
        Task { await restoreSession() }
    }

    func signIn(email: String, password: String) async throws {
        let body = LoginRequest(email: email, password: password)
        let request = try api.makeRequest(path: "/auth/login", method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)

        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        try keychain.save(key: "auth_token", value: loginResponse.token)
        try keychain.save(key: "refresh_token", value: loginResponse.refreshToken)
        api.setAuthToken(loginResponse.token)

        self.currentUser = loginResponse.user
        self.isSignedIn = true
    }

    func signUp(email: String, password: String) async throws {
        let body = SignUpRequest(email: email, password: password)
        let request = try api.makeRequest(path: "/auth/register", method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)

        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        try keychain.save(key: "auth_token", value: loginResponse.token)
        api.setAuthToken(loginResponse.token)

        self.currentUser = loginResponse.user
        self.isSignedIn = true
    }

    func signOut() throws {
        try keychain.delete(key: "auth_token")
        try keychain.delete(key: "refresh_token")
        api.setAuthToken(nil)
        self.currentUser = nil
        self.isSignedIn = false
    }

    func refreshToken() async throws {
        guard let refreshToken = try keychain.load(key: "refresh_token") else {
            throw AppError.unauthorized
        }
        let body = RefreshRequest(refreshToken: refreshToken)
        let request = try api.makeRequest(path: "/auth/refresh", method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try api.validateResponse(response)

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        try keychain.save(key: "auth_token", value: tokenResponse.token)
        api.setAuthToken(tokenResponse.token)
    }

    private func restoreSession() async {
        guard let token = try? keychain.load(key: "auth_token") else { return }
        api.setAuthToken(token)

        do {
            let request = try api.makeRequest(path: "/auth/me", method: "GET")
            let (data, response) = try await URLSession.shared.data(for: request)
            try api.validateResponse(response)
            let user = try JSONDecoder().decode(AppUser.self, from: data)
            self.currentUser = user
            self.isSignedIn = true
        } catch {
            // Token expired, try refresh
            do {
                try await refreshToken()
                try await restoreSession()
            } catch {
                try? signOut()
            }
        }
    }
}

// Supporting types
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let refreshToken: String
    let user: AppUser
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

struct TokenResponse: Decodable {
    let token: String
}
```

**Keychain helper:**

```swift
final class KeychainHelper {
    func save(key: String, value: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppError.keychainError(status)
        }
    }

    func load(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

---

### 4. Apple-Only (Sign in with Apple)

**Required imports:**

```swift
import AuthenticationServices
```

**After (Apple-only auth):**

```swift
import AuthenticationServices

final class AuthManagerApple: AuthManagerProtocol {
    var currentUser: AppUser?
    var isSignedIn: Bool = false

    private let keychain = KeychainHelper()

    init() {
        Task { await restoreSession() }
    }

    func signInWithApple(
        authorization: ASAuthorization
    ) async throws {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AppError.invalidCredential
        }

        let userId = credential.user
        let email = credential.email
        let fullName = [
            credential.fullName?.givenName,
            credential.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")

        // Store user ID for session restoration
        try keychain.save(key: "apple_user_id", value: userId)

        // Store name/email on first sign-in (Apple only provides these once)
        if !fullName.isEmpty {
            try keychain.save(key: "apple_user_name", value: fullName)
        }
        if let email {
            try keychain.save(key: "apple_user_email", value: email)
        }

        self.currentUser = AppUser(
            id: userId,
            email: email ?? (try? keychain.load(key: "apple_user_email")),
            displayName: fullName.isEmpty ? (try? keychain.load(key: "apple_user_name")) : fullName,
            photoURL: nil
        )
        self.isSignedIn = true
    }

    func signOut() throws {
        try keychain.delete(key: "apple_user_id")
        self.currentUser = nil
        self.isSignedIn = false
    }

    func deleteAccount() async throws {
        // Revoke Apple ID credential
        // Note: Full account deletion may require server-side token revocation
        try signOut()
    }

    private func restoreSession() async {
        guard let userId = try? keychain.load(key: "apple_user_id") else { return }

        // Verify credential state with Apple
        let provider = ASAuthorizationAppleIDProvider()
        do {
            let state = try await provider.credentialState(forUserID: userId)
            switch state {
            case .authorized:
                self.currentUser = AppUser(
                    id: userId,
                    email: try? keychain.load(key: "apple_user_email"),
                    displayName: try? keychain.load(key: "apple_user_name"),
                    photoURL: nil
                )
                self.isSignedIn = true
            case .revoked, .notFound:
                try? signOut()
            default:
                break
            }
        } catch {
            // Network error — assume still authorized if we have stored credentials
            self.currentUser = AppUser(
                id: userId,
                email: try? keychain.load(key: "apple_user_email"),
                displayName: try? keychain.load(key: "apple_user_name"),
                photoURL: nil
            )
            self.isSignedIn = true
        }
    }
}
```

---

## Analytics Backends

### 1. Firebase Analytics

**Required imports:**

```swift
import FirebaseAnalytics
```

**SPM dependency:** `FirebaseAnalytics` from `firebase-ios-sdk`

**Before (mock):**

```swift
final class LogManagerMock: LogManagerProtocol {
    func trackEvent(event: LoggableEvent) {
        #if DEBUG
        print("[Mock Analytics] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }

    func setUserProperty(name: String, value: String?) {}
    func setUserId(_ id: String?) {}
}
```

**After (Firebase Analytics):**

```swift
import FirebaseAnalytics

final class LogManagerFirebase: LogManagerProtocol {
    func trackEvent(event: LoggableEvent) {
        switch event.type {
        case .analytic:
            Analytics.logEvent(event.eventName, parameters: event.parameters)
        case .error:
            Analytics.logEvent("error_\(event.eventName)", parameters: event.parameters)
        case .debug:
            #if DEBUG
            print("[Firebase] \(event.eventName): \(event.parameters ?? [:])")
            #endif
        }
    }

    func setUserProperty(name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
    }

    func setUserId(_ id: String?) {
        Analytics.setUserID(id)
    }
}
```

---

### 2. Mixpanel

**Required imports:**

```swift
import Mixpanel
```

**SPM dependency:** `https://github.com/mixpanel/mixpanel-swift`

**Initialization:**

```swift
Mixpanel.initialize(token: Configuration.mixpanelToken, trackAutomaticEvents: true)
```

**After (Mixpanel):**

```swift
import Mixpanel

final class LogManagerMixpanel: LogManagerProtocol {
    func trackEvent(event: LoggableEvent) {
        switch event.type {
        case .analytic:
            let properties = convertToMixpanelProperties(event.parameters)
            Mixpanel.mainInstance().track(event: event.eventName, properties: properties)
        case .error:
            let properties = convertToMixpanelProperties(event.parameters)
            Mixpanel.mainInstance().track(event: "error_\(event.eventName)", properties: properties)
        case .debug:
            #if DEBUG
            print("[Mixpanel] \(event.eventName): \(event.parameters ?? [:])")
            #endif
        }
    }

    func setUserProperty(name: String, value: String?) {
        if let value {
            Mixpanel.mainInstance().people.set(property: name, to: value)
        } else {
            Mixpanel.mainInstance().people.unset(properties: [name])
        }
    }

    func setUserId(_ id: String?) {
        if let id {
            Mixpanel.mainInstance().identify(distinctId: id)
        } else {
            Mixpanel.mainInstance().reset()
        }
    }

    private func convertToMixpanelProperties(_ parameters: [String: Any]?) -> Properties? {
        guard let parameters else { return nil }
        var props = Properties()
        for (key, value) in parameters {
            if let stringValue = value as? String {
                props[key] = stringValue
            } else if let intValue = value as? Int {
                props[key] = intValue
            } else if let doubleValue = value as? Double {
                props[key] = doubleValue
            } else if let boolValue = value as? Bool {
                props[key] = boolValue
            } else {
                props[key] = "\(value)"
            }
        }
        return props
    }
}
```

---

### 3. PostHog

**Required imports:**

```swift
import PostHog
```

**SPM dependency:** `https://github.com/PostHog/posthog-ios`

**Initialization:**

```swift
let config = PostHogConfig(apiKey: Configuration.posthogAPIKey)
config.host = Configuration.posthogHost
PostHogSDK.shared.setup(config)
```

**After (PostHog):**

```swift
import PostHog

final class LogManagerPostHog: LogManagerProtocol {
    func trackEvent(event: LoggableEvent) {
        switch event.type {
        case .analytic:
            PostHogSDK.shared.capture(event.eventName, properties: convertProperties(event.parameters))
        case .error:
            PostHogSDK.shared.capture(
                "error_\(event.eventName)",
                properties: convertProperties(event.parameters)
            )
        case .debug:
            #if DEBUG
            print("[PostHog] \(event.eventName): \(event.parameters ?? [:])")
            #endif
        }
    }

    func setUserProperty(name: String, value: String?) {
        if let value {
            PostHogSDK.shared.capture("$set", userProperties: [name: value])
        }
    }

    func setUserId(_ id: String?) {
        if let id {
            PostHogSDK.shared.identify(id)
        } else {
            PostHogSDK.shared.reset()
        }
    }

    private func convertProperties(_ parameters: [String: Any]?) -> [String: Any]? {
        parameters
    }
}
```

---

### 4. Custom Endpoint

**Required imports:**

```swift
import Foundation
```

**After (Custom analytics endpoint):**

```swift
final class LogManagerCustom: LogManagerProtocol {
    private let api: APIClient
    private var userId: String?
    private var pendingEvents: [EventPayload] = []
    private var flushTimer: Timer?

    init(api: APIClient) {
        self.api = api
        startFlushTimer()
    }

    func trackEvent(event: LoggableEvent) {
        switch event.type {
        case .analytic, .error:
            let payload = EventPayload(
                name: event.eventName,
                parameters: event.parameters,
                timestamp: Date(),
                userId: userId,
                type: event.type == .error ? "error" : "event"
            )
            pendingEvents.append(payload)

            // Flush immediately if buffer is large
            if pendingEvents.count >= 10 {
                Task { await flush() }
            }
        case .debug:
            #if DEBUG
            print("[Custom] \(event.eventName): \(event.parameters ?? [:])")
            #endif
        }
    }

    func setUserProperty(name: String, value: String?) {
        let payload = EventPayload(
            name: "$set_user_property",
            parameters: [name: value as Any],
            timestamp: Date(),
            userId: userId,
            type: "user_property"
        )
        pendingEvents.append(payload)
    }

    func setUserId(_ id: String?) {
        self.userId = id
        if let id {
            let payload = EventPayload(
                name: "$identify",
                parameters: nil,
                timestamp: Date(),
                userId: id,
                type: "identify"
            )
            pendingEvents.append(payload)
        }
    }

    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.flush() }
        }
    }

    private func flush() async {
        guard !pendingEvents.isEmpty else { return }
        let events = pendingEvents
        pendingEvents = []

        do {
            let request = try api.makeRequest(
                path: "/events/batch",
                method: "POST",
                body: BatchEventRequest(events: events)
            )
            let (_, response) = try await URLSession.shared.data(for: request)
            try api.validateResponse(response)
        } catch {
            // Re-add events to pending queue on failure
            pendingEvents.insert(contentsOf: events, at: 0)
        }
    }
}

struct EventPayload: Codable {
    let name: String
    let parameters: [String: AnyCodable]?
    let timestamp: Date
    let userId: String?
    let type: String

    init(name: String, parameters: [String: Any]?, timestamp: Date, userId: String?, type: String) {
        self.name = name
        self.parameters = parameters?.mapValues { AnyCodable($0) }
        self.timestamp = timestamp
        self.userId = userId
        self.type = type
    }
}

struct BatchEventRequest: Encodable {
    let events: [EventPayload]
}
```

---

### 5. None (Keep Mock)

No changes to the LogManager. The existing mock implementation stays:

```swift
final class LogManagerMock: LogManagerProtocol {
    func trackEvent(event: LoggableEvent) {
        #if DEBUG
        print("[Mock] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }

    func setUserProperty(name: String, value: String?) {}
    func setUserId(_ id: String?) {}
}
```

---

## Common Patterns

### AppError Enum

All backends should map errors to a shared `AppError` type for consistent error handling across the app:

```swift
enum AppError: LocalizedError {
    case notFound
    case unauthorized
    case conflict
    case networkError
    case serverError
    case rateLimited(retryAfter: Double? = nil)
    case quotaExceeded
    case invalidURL
    case invalidResponse
    case noData
    case invalidCredential
    case keychainError(OSStatus)
    case graphQL(String)
    case notImplemented(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "The requested item was not found."
        case .unauthorized: return "You are not authorized. Please sign in again."
        case .conflict: return "A conflict occurred. Please try again."
        case .networkError: return "Network connection failed. Check your internet and try again."
        case .serverError: return "Server error. Please try again later."
        case .rateLimited: return "Too many requests. Please wait a moment."
        case .quotaExceeded: return "Storage quota exceeded."
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Invalid response from server."
        case .noData: return "No data received."
        case .invalidCredential: return "Invalid credentials."
        case .keychainError: return "Secure storage error."
        case .graphQL(let message): return "GraphQL error: \(message)"
        case .notImplemented(let feature): return "\(feature) is not yet implemented."
        case .unknown(let message): return message
        }
    }
}
```

### Configuration Pattern

Centralize service credentials in a Configuration struct that reads from xcconfig or environment:

```swift
enum Configuration {
    // Firebase — reads from GoogleService-Info.plist automatically

    // Supabase
    static var supabaseURL: String {
        Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    }
    static var supabaseAnonKey: String {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }

    // Mixpanel
    static var mixpanelToken: String {
        Bundle.main.infoDictionary?["MIXPANEL_TOKEN"] as? String ?? ""
    }

    // PostHog
    static var posthogAPIKey: String {
        Bundle.main.infoDictionary?["POSTHOG_API_KEY"] as? String ?? ""
    }
    static var posthogHost: String {
        Bundle.main.infoDictionary?["POSTHOG_HOST"] as? String ?? "https://us.i.posthog.com"
    }

    // REST/GraphQL API
    static var apiBaseURL: String {
        Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
    }
}
```

### AnyCodable Helper

For GraphQL and custom analytics, a simple AnyCodable wrapper:

```swift
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues(\.value)
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map(\.value)
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String: try container.encode(string)
        case let int as Int: try container.encode(int)
        case let double as Double: try container.encode(double)
        case let bool as Bool: try container.encode(bool)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }

    var stringValue: String? { value as? String }
    var intValue: Int? { value as? Int }
    var doubleValue: Double? { value as? Double }
    var boolValue: Bool? { value as? Bool }
}
```
