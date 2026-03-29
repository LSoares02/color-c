# 🎨 Color C

**Color C** is a Flutter app designed to help people with color blindness identify and explore colors in the real world.

The concept is simple: take a photo or select an image, tap on a spot, and instantly get the exact color — including its name, hex code, perceptual description, and complementary palette suggestions.

> _"Color C" is a wordplay on "Color See", the opposite of "Colorblind"!_

# 🧪 Features

- 📷 **Capture via camera** or **select from gallery**
- 🖱️ **Tap anywhere on the image** to detect the exact color
- 🟩 **Live preview** with background color, hex code, and color name
- 🌐 Integration with [The Color API](https://www.thecolorapi.com/) for semantic color naming
- 🎨 **Automatic theme adaptation** based on the detected color
- 🎨 **Complementary palettes** via API (monochrome, analogic, complement, triad, quad) with local fallback
- 🧠 **Perceptual color description** ("looks like purple", "warm · vivid · medium") — accessible for color blind users
- 📋 **Copy hex code** with a single tap
- 💾 **Save favourite palettes** with local persistence (up to 50) and quick access from the home screen
- 🔔 **Haptic feedback** on color detection
- 🌐 **Network reliability**: timeout, loading states, auto-retry, and error toasts

# 🛠️ Tech Stack

- **Flutter** / **Material 3**
- **Provider** for state management
- **shared_preferences** for local palette persistence
- **Image Picker** + **Photo View**
- **HTTP** for external API integration

# 🚀 How to Run Locally

1. Clone the project:

   ```
   git clone https://github.com/LSoares02/color-c.git
   cd color-c
   ```

2. Install dependencies:

   ```
   flutter pub get
   ```

3. Run on an emulator or physical device:

   ```
   flutter run
   ```

# 📱 Platforms

✅ Android
✅ iOS

> 🧪 Tested on: Android API 35 (emulator) and iOS 18 (iPhone 12 mini)

> _"See the unseen. Decode the colors." — Color C_
