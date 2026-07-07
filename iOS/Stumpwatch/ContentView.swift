import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: JobEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.treeLocation)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Stumpwatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: JobEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.treeLocation).font(Theme.bodyFont).fontWeight(.semibold)
            Text(entry.workType).font(Theme.captionFont).foregroundStyle(.secondary)
            if !entry.notes.isEmpty {
                Text(entry.notes).font(Theme.captionFont).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var treeLocation: String
    @State private var workType: String
    @State private var dateDone: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private enum Field { case f1, f2, f3, f4 }

    let existing: JobEntry?
    let onSave: (JobEntry) -> Void

    init(entry: JobEntry?, onSave: @escaping (JobEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _treeLocation = State(initialValue: entry?.treeLocation ?? "")
        _workType = State(initialValue: entry?.workType ?? "")
        _dateDone = State(initialValue: entry?.dateDone ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Treelocation", text: $treeLocation)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_treeLocation")
                    TextField("Worktype", text: $workType)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_workType")
                    TextField("Datedone", text: $dateDone)
                        .focused($focusedField, equals: .f3)
                        .accessibilityIdentifier("field_dateDone")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .f4)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existing == nil ? "New Job" : "Edit Job")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = JobEntry(
                            id: existing?.id ?? UUID(),
                            treeLocation: treeLocation,
                            workType: workType,
                            dateDone: dateDone,
                            notes: notes,
                            createdAt: existing?.createdAt ?? Date()
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(treeLocation.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
