# 🎨 Color C

**Color C** is a Flutter app designed to help people with color blindness identify and explore colors in the real world.

The concept is simple: take a photo or select an image, tap on a spot, and instantly get the exact color — including its name, hexadecimal code, and even complementary palette suggestions.

> _"Color C" is a wordplay on "Color See", the opposite of "Colorblind"!_

# 🧪 Features (v1)

- 📷 **Capture via camera** or **select from gallery**
- 🖱️ **Tap anywhere on the image** to detect a color
- 🟩 **Live preview** with background color, hex code, and color name
- 🌐 Integration with [The Color API](https://www.thecolorapi.com/) for semantic color naming
- 🎨 Automatic theme adaptation based on the detected color
- 🧠 Designed with accessibility and aesthetics in mind

# 🛠️ Tech Stack

- **Flutter**
- **Material 3**
- **Provider** for state management
- **Image Picker**
- **Photo View**
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

> 🧪 Tested on: Android API 35 (emulator), and iOS 18 (iPhone 12 mini)

# ✨ Upcoming Features

- 💥 "Bubble" animation with transition to suggestion screen

- 🎨 Generation of complementary, analogous, and triadic color palettes

- 📊 History of saved colors

> _"See the unseen. Decode the colors." — Color C_
