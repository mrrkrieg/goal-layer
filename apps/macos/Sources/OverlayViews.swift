import SwiftUI

struct OverlayRoot: View {
    @Bindable var state: SpikeState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if state.expanded { expandedContent } else { pill }
        }
        .font(.system(size: state.largerText ? 17 : 14))
        .foregroundStyle(colorScheme == .dark ? Color(red: 0.957, green: 0.953, blue: 0.937) : Color(red: 0.125, green: 0.149, blue: 0.188))
        .background(colorScheme == .dark ? Palette.night : Color(red: 0.961,green: 0.953,blue: 0.933))
        .clipShape(RoundedRectangle(cornerRadius: state.expanded ? 22 : 18))
        .overlay(RoundedRectangle(cornerRadius: state.expanded ? 22 : 18).stroke(.primary.opacity(0.12), lineWidth: 1))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: state.pulse)
    }

    private var pill: some View {
        Button(action: state.openPanel) {
            HStack(spacing: 10) {
                CompanionView(trait: state.trait, portrait: true).frame(width: 26, height: 26)
                Text(state.feedback.isEmpty ? state.nextAction : state.feedback).lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.down").font(.system(size: 10, weight: .semibold))
            }.padding(.horizontal, 14).frame(maxWidth: .infinity, maxHeight: .infinity).contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Goal Layer. \(state.nextAction). Observation off.")
        .accessibilityIdentifier("openOverlay")
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Goal Layer", systemImage: "sparkle").font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: state.openWindow) { Image(systemName: "arrow.up.left.and.arrow.down.right") }
                    .accessibilityLabel("Open larger planning window").help("Open larger planning window")
                Button(action: state.collapse) { Image(systemName: "chevron.up") }
                    .accessibilityLabel("Collapse overlay").help("Collapse overlay (Escape)").accessibilityIdentifier("collapseOverlay")
            }.buttonStyle(.plain).padding(.horizontal, 20).padding(.vertical, 15)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ObservatoryView(trait: state.trait, animated: !state.quiet)
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                        Text("Local preview · Observation off").font(.system(size: 12))
                        Spacer()
                        Text("M1 SPIKE").font(.system(size: 10,weight: .semibold)).padding(5).background(.primary.opacity(0.06),in: Capsule())
                    }.foregroundStyle(.secondary)
                    if state.isDemo { demoGoal } else { firstGoal }
                    Divider()
                    Picker("Character style", selection: $state.trait) {
                        ForEach(CharacterTrait.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented).accessibilityLabel("Character style, cosmetic only")
                    Text("Native preview uses synthetic data. Rewards and saved goals arrive in M2.")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }.padding(.horizontal, 20).padding(.bottom, 20)
            }
            Divider()
            HStack {
                Button("Plan", action: state.openWindow)
                Spacer()
                Text("Community · planned").foregroundStyle(.secondary)
                Spacer()
                Button("Settings", action: state.openWindow)
            }.font(.system(size: 12)).buttonStyle(.plain).padding(.horizontal, 20).padding(.vertical, 14)
        }
        .onExitCommand(perform: state.collapse)
    }

    private var demoGoal: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Publish a working shortcut utility").font(.system(size: state.largerText ? 24 : 21,weight: .semibold)).fixedSize(horizontal: false,vertical: true)
            Text("0 of 3 outcome criteria accepted").font(.system(size: 13)).foregroundStyle(.secondary)
            Text("Next quest").font(.system(size: 11,weight: .medium)).foregroundStyle(.secondary)
            Text("Resolve the implementation question").font(.system(size: state.largerText ? 20 : 17,weight: .medium)).fixedSize(horizontal: false,vertical: true)
            Text("Done when a short decision note compares two approaches against the agreed requirements.")
                .foregroundStyle(.secondary).fixedSize(horizontal: false,vertical: true)
            HStack {
                Text("Planned: 40 personal XP").font(.system(size: 12,weight: .medium))
                Spacer()
                Button("Edit draft", action: state.openWindow).buttonStyle(.borderedProminent).tint(colorScheme == .dark ? Palette.mint : Color(red: 0.14,green: 0.43,blue: 0.38))
            }
        }
    }

    private var firstGoal: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("A little world for meaningful work.").font(.system(size: 22,weight: .semibold))
            Text("What would you like to make progress on?").foregroundStyle(.secondary)
            TextField("Describe your goal", text: $state.draft).textFieldStyle(.roundedBorder).accessibilityIdentifier("goalDraft")
            Button("Continue draft", action: state.openWindow).buttonStyle(.borderedProminent)
            Text("Your draft stays here when you collapse the panel.").font(.system(size: 12)).foregroundStyle(.secondary)
        }
    }
}

struct PlanningWindowView: View {
    @Bindable var state: SpikeState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("Goal Layer · native preview",systemImage: "sparkle").font(.largeTitle.bold())
                ObservatoryView(trait: state.trait)
                Text("Goal draft").font(.title2.bold())
                TextField("What would you like to achieve?",text: $state.draft,axis: .vertical)
                    .textFieldStyle(.roundedBorder).lineLimit(3...7).accessibilityIdentifier("windowGoalDraft")
                Text("This M1 preview tests the Mac shell. It keeps your draft during this launch. Creating an approved goal and awarding XP are planned for M2.")
                    .foregroundStyle(.secondary)
                Picker("Character style (cosmetic)",selection: $state.trait) { ForEach(CharacterTrait.allCases) { Text($0.rawValue).tag($0) } }
                Toggle("Larger overlay text",isOn: $state.largerText)
                Toggle("Quiet feedback",isOn: $state.quiet)
                Text("Observation is off. AI and community are not connected.").foregroundStyle(.secondary)
                Text("Click the menu bar observatory to hide or restore the overlay, choose a display and top-right or top-center position, and enter presentation mode. No global shortcut is assigned.").foregroundStyle(.secondary)
                Button("Return to overlay",action: state.openPanel).buttonStyle(.borderedProminent)
            }.padding(32).frame(maxWidth: 650)
        }.frame(minWidth: 460,minHeight: 500)
    }
}
