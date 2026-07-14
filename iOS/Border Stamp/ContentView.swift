import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.country).font(Theme.headlineFont)
                            Text(entry.crossingPoint).font(Theme.bodyFont).foregroundColor(.secondary)
                            HStack {
                                Text("\(entry.stayDays, specifier: "%.1f") days")
                                Spacer()
                                Text("\(entry.visitCount, specifier: "%.1f")")
                            }
                            .font(.caption)
                            .foregroundColor(Theme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Border Stamp")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var country: String
    @State private var crossingPoint: String
    @State private var stayDaysText: String
    @State private var visitCountText: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private let originalID: UUID
    private let onSave: (Entry) -> Void

    enum Field { case f1, f2, n1, n2, notes }

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _country = State(initialValue: entry?.country ?? "")
        _crossingPoint = State(initialValue: entry?.crossingPoint ?? "")
        _stayDaysText = State(initialValue: entry != nil ? String(entry!.stayDays) : "")
        _visitCountText = State(initialValue: entry != nil ? String(entry!.visitCount) : "")
        _notes = State(initialValue: entry?.notes ?? "")
        originalID = entry?.id ?? UUID()
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("country") {
                    TextField("country", text: $country)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_country")
                }
                Section("crossingPoint") {
                    TextField("crossingPoint", text: $crossingPoint)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_crossingPoint")
                }
                Section("Details") {
                    TextField("stayDays", text: $stayDaysText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n1)
                        .accessibilityIdentifier("field_stayDays")
                    TextField("visitCount", text: $visitCountText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n2)
                        .accessibilityIdentifier("field_visitCount")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(originalID == UUID() ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: originalID,
                            country: country,
                            crossingPoint: crossingPoint,
                            stayDays: Double(stayDaysText) ?? 0,
                            visitCount: Double(visitCountText) ?? 0,
                            notes: notes
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(country.isEmpty)
                }
            }
        }
    }
}
