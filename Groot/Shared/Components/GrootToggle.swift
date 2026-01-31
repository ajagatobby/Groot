import SwiftUI

// MARK: - Groot Toggle

struct GrootToggle: View {
    @Binding var isOn: Bool
    let label: String?
    let subtitle: String?
    let icon: String?
    
    init(
        isOn: Binding<Bool>,
        label: String? = nil,
        subtitle: String? = nil,
        icon: String? = nil
    ) {
        self._isOn = isOn
        self.label = label
        self.subtitle = subtitle
        self.icon = icon
    }
    
    var body: some View {
        Button {
            withAnimation(.grootSnappy) {
                isOn.toggle()
            }
            GrootHaptics.selection()
        } label: {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isOn ? Color.grootShield : Color.grootPebble)
                        .frame(width: 32)
                }
                
                if let label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(label.lowercased())
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.grootBark)
                        
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.grootStone)
                        }
                    }
                }
                
                Spacer()
                
                GrootToggleSwitch(isOn: $isOn)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Toggle Switch Component

struct GrootToggleSwitch: View {
    @Binding var isOn: Bool
    
    private let width: CGFloat = 52
    private let height: CGFloat = 32
    private let knobSize: CGFloat = 26
    private let padding: CGFloat = 3
    
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color.grootShield : Color.grootMist)
                .frame(width: width, height: height)
            
            Circle()
                .fill(Color.white)
                .frame(width: knobSize, height: knobSize)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                .padding(padding)
        }
        .animation(.grootSnappy, value: isOn)
        .onTapGesture {
            withAnimation(.grootSnappy) {
                isOn.toggle()
            }
            GrootHaptics.selection()
        }
    }
}

// MARK: - Toggle Row (List Style)

struct GrootToggleRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    @Binding var isOn: Bool
    
    init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = .grootShield,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: 14) {
            if let icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title.lowercased())
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            GrootToggleSwitch(isOn: $isOn)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Checkbox

struct GrootCheckbox: View {
    @Binding var isChecked: Bool
    let label: String?
    
    init(isChecked: Binding<Bool>, label: String? = nil) {
        self._isChecked = isChecked
        self.label = label
    }
    
    var body: some View {
        Button {
            withAnimation(.grootSnappy) {
                isChecked.toggle()
            }
            GrootHaptics.selection()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isChecked ? Color.grootShield : Color.grootCloud)
                        .frame(width: 24, height: 24)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? Color.grootShield : Color.grootMist, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                
                if let label {
                    Text(label)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Radio Button

struct GrootRadioButton: View {
    let isSelected: Bool
    let label: String?
    let action: () -> Void
    
    init(isSelected: Bool, label: String? = nil, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
            GrootHaptics.selection()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.grootShield : Color.grootMist, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.grootShield)
                            .frame(width: 14, height: 14)
                    }
                }
                .animation(.grootSnappy, value: isSelected)
                
                if let label {
                    Text(label)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview("Groot Toggles") {
    ScrollView {
        VStack(spacing: 24) {
            GrootText("toggle switch", style: .heading)
            
            VStack(spacing: 16) {
                GrootToggle(
                    isOn: .constant(true),
                    label: "block unknown callers",
                    subtitle: "Automatically block calls from numbers not in your contacts",
                    icon: "phone.down.fill"
                )
                
                GrootToggle(
                    isOn: .constant(false),
                    label: "silent mode",
                    subtitle: "Block calls without any notification",
                    icon: "bell.slash.fill"
                )
            }
            .padding(16)
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            GrootText("toggle rows", style: .heading)
            
            VStack(spacing: 0) {
                GrootToggleRow(
                    "country blocking",
                    subtitle: "Block calls from specific countries",
                    icon: "globe",
                    iconColor: .grootSky,
                    isOn: .constant(true)
                )
                Divider().padding(.leading, 50)
                GrootToggleRow(
                    "pattern blocking",
                    subtitle: "Block numbers matching patterns",
                    icon: "number",
                    iconColor: .grootViolet,
                    isOn: .constant(false)
                )
            }
            .padding(16)
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            GrootText("checkboxes", style: .heading)
            
            VStack(alignment: .leading, spacing: 12) {
                GrootCheckbox(isChecked: .constant(true), label: "Block robocalls")
                GrootCheckbox(isChecked: .constant(false), label: "Block telemarketers")
                GrootCheckbox(isChecked: .constant(true), label: "Block scam likely")
            }
            .padding(16)
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            GrootText("radio buttons", style: .heading)
            
            VStack(alignment: .leading, spacing: 12) {
                GrootRadioButton(isSelected: true, label: "Block all unknown") { }
                GrootRadioButton(isSelected: false, label: "Block international only") { }
                GrootRadioButton(isSelected: false, label: "Custom rules only") { }
            }
            .padding(16)
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
