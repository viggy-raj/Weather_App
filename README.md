# Weather App 🌦️

A sleek and modern Flutter application that provides real-time weather updates and forecasts based on your current location.

## ✨ Features

- **Real-time Weather**: Get current temperature, sky conditions, and weather descriptions.
- **Geolocation Support**: Automatically detects your current location to provide accurate local data.
- **Hourly Forecast**: View a detailed 5-day / 3-hour weather forecast in a scrollable list.
- **Additional Metrics**: Access critical weather details including:
  - 💧 Humidity
  - 💨 Wind Speed
  - 🌊 Air Pressure
- **Modern UI**: Features a clean design with glassmorphism effects and intuitive icons.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An API Key from [OpenWeatherMap](https://openweathermap.org/api).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/viggy-raj/Weather_App.git
   cd Weather_App
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the root directory and add your OpenWeatherMap API key:
   ```env
   Weather_API_Key=YOUR_API_KEY_HERE
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🛠️ Built With

- **Flutter & Dart**: For a cross-platform mobile experience.
- **OpenWeatherMap API**: Providing reliable global weather data.
- **Packages**:
  - `http`: For API requests.
  - `geolocator` & `geocoding`: For location services.
  - `flutter_dotenv`: For secure environment variable management.
  - `intl`: For date and time formatting.
  - `flutter_launcher_icons`: For automated app icon generation.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details (if applicable).
