import SwiftUI

// MARK: - Root view

struct ContentView: View {
    @StateObject private var service = JokeService()

    @State private var language:     AppLanguage = .english
    @State private var selectedType: ItemType    = .joke
    @State private var index:        Int         = 0
    @State private var isRevealed:   Bool        = false

    var current: JokeItem? {
        service.jokes.isEmpty ? nil : service.jokes[index]
    }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                headerBar
                typePicker
                Spacer()
                centerContent
                Spacer()
                if !service.jokes.isEmpty {
                    bottomBar
                }
            }
        }
        .onAppear { load() }
        .onChange(of: selectedType) { _ in load() }
        .onChange(of: language)     { _ in load() }
    }

    // MARK: - Sub-views

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.4, green: 0.2, blue: 0.8),
                     Color(red: 0.1, green: 0.5, blue: 0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var headerBar: some View {
        HStack {
            Text("😂 LaughBox")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Spacer()
            languageToggle
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var languageToggle: some View {
        Menu {
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                Button {
                    language = lang
                } label: {
                    Text("\(lang.flag)  \(lang.displayName)")
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(language.flag)
                Text(language.rawValue)
                    .font(.subheadline.bold())
                Image(systemName: "chevron.down")
                    .font(.caption2.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.25))
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
    }

    private var typePicker: some View {
        Picker("", selection: $selectedType) {
            ForEach(ItemType.allCases, id: \.self) { type in
                Text(type.label(for: language)).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var centerContent: some View {
        if service.isLoading {
            loadingView
        } else if let error = service.errorMessage {
            errorView(error)
        } else if let item = current {
            CardView(item: item, language: language, isRevealed: $isRevealed)
                .id(item.id)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundStyle(.white.opacity(0.8))
                .font(.subheadline)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.8))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 32)
            Button(action: load) {
                Text("Try again")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(red: 0.4, green: 0.2, blue: 0.8))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            Text("\(index + 1) \(language.counter) \(service.jokes.count)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Button(action: next) {
                Text(language.nextButton)
                    .font(.title3.bold())
                    .foregroundStyle(Color(red: 0.4, green: 0.2, blue: 0.8))
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
        }
        .padding(.bottom, 40)
    }

    // MARK: - Logic

    private func load() {
        index      = 0
        isRevealed = false
        Task { await service.fetch(language: language, type: selectedType) }
    }

    private func next() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isRevealed = false
            if index < service.jokes.count - 1 {
                index += 1
            } else {
                load() // fetch a fresh batch when we reach the end
            }
        }
    }
}

// MARK: - Card

struct CardView: View {
    let item:     JokeItem
    let language: AppLanguage
    @Binding var isRevealed: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text(item.question)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)

            Divider()
                .background(Color.white.opacity(0.4))

            if isRevealed {
                Text(item.answer)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        isRevealed = true
                    }
                } label: {
                    Text(language.tapReveal)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1))
                }
                .transition(.opacity)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.3), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
