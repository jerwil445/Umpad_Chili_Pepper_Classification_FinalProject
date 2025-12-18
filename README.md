
<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&pause=1000&color=E8690F&center=true&vCenter=true&width=650&lines=Hey+%F0%9F%91%8B+I'm+Jerwil+Umpad;Flutter+%7C+Web+%7C+Backend+Developer" />
</p>



<h3 align="center">🎯IT Student. Aspiring Full-Stack & Front-End Developer — passionate about building clean, efficient, and user-friendly web applications.<br>Based in Butuan City, Agusan del Norte, Northern Mindanao, Philippines. 🇵🇭</h3>
<hr>
<br clear="both">

<img align="right" height="175" src="https://mir-s3-cdn-cf.behance.net/project_modules/hd/06f21a161921919.63cd7887d0a70.gif"  />

About Me
<p align="left">
I love turning ideas into clean, functional, and user-friendly web applications. Whether it’s building responsive interfaces, writing backend logic, or experimenting with new technologies — I’m always excited to learn, create, and grow as a developer.<br><br>
💡 Always building. Always learning. Always improving.
</p>


<br clear="both">
<hr>
🚀 What I Do / What I’m Learning
<p align="left">
  
💻 Skilled in HTML, CSS, JavaScript, PHP (Laravel), MySQL, TailwindCSS, Bootstrap, Chart.js, and building Flutter mobile apps.<br>
🔧 Currently working on a Hotel Booking System, a Flutter Chili Pepper Test App, and AgriConnect for product–demand matching.<br>
🌱 Always learning modern frameworks, clean architecture, and best practices.<br>
📚 Passionate about web development, scalable systems, and writing clean, maintainable code.
</p>
<hr>
<h3 align="center">Skills</h3>
## 🧠 Programming Languages

[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=000)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![C++](https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)](https://isocpp.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)](https://www.oracle.com/java/)
[![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

## 🎨 Frontend
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML)
[![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/CSS)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-7952B3?style=for-the-badge&logo=bootstrap&logoColor=white)](https://getbootstrap.com/)

## 🗄️ Backend & Database
[![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)

## 📱 Mobile Development
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=black)](https://developer.android.com/)
[![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)](https://developer.android.com/studio)

## 🛠️ Tools & Version Control
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)

 ## 🌶️ Chili Pepper Identifier – Flutter Application

**Chili Pepper Identifier** is a cross-platform mobile app built with **Flutter** that detects and classifies various chili pepper types using **image recognition technology**. Powered by **TensorFlow Lite**, it performs **real-time image classification on-device**, eliminating the need for constant internet connectivity.  

---

### 📸 Image Input Methods
Users can provide images through **two main methods**:

- **Camera Capture** – Take photos in real-time using the device camera.
- **Gallery Selection** – Select existing images from the device’s gallery.

The app processes images using a **pre-trained ML model** stored in the `assets/tflite` directory:

| File | Purpose |
|------|---------|
| `model_unquant.tflite` | Machine learning model for inference |
| `labels.txt` | List of classification categories |

**Detection results** include the identified chili pepper type and **confidence percentage**, displayed with clear visual feedback.

---

### ☁️ Data Persistence & History Tracking
The app ensures **robust data storage** and history tracking using a **dual approach**:

- **Cloud Storage** – Firebase Realtime Database for history tracking and cloud backup.
- **Local Storage** – SharedPreferences for offline access and protection against network failures.

---

### 🎨 User Interface
- **Vibrant color scheme** – Green & red gradients reflecting chili pepper theme 🌶️  
- **Responsive design** – Widgets adapt to various screen sizes and orientations  
- **Intuitive navigation**:
  - **Landing page** – Introduces the app  
  - **Camera interface** – Performs real-time image processing  
  - **Results page** – Displays chronological list of past detections with timestamps  

---

### ⚙️ Architecture & Functionality
- **Flutter State Management** – StatefulWidgets for dynamic UI updates  
- **Separation of Concerns** – Each feature in a distinct file for maintainability  
- **Error Handling** – Handles camera initialization failures, model loading errors, and network issues  
- **Permissions Management** – Requests camera and storage permissions seamlessly  

---

### 🚀 Highlights
- Real-time on-device chili pepper classification  
- Dual storage: Cloud (Firebase) + Local (SharedPreferences)  
- Colorful and responsive UI with intuitive navigation  
- Handles errors and permissions gracefully  

## 📱 Application Screenshots

| Homepage | Guide Popup | Scanner Page | Profile Page|
|----------|--------------|-----------------|-----------------|
| <img src="Application_Screenshots/Homepage.jpg" width="200" alt="Homepage" /> | <img src="Application_Screenshots/Pop_up_Guide.jpg" width="200" alt="Guide Popup" /> | <img src="Application_Screenshots/Scanner_page.jpg" width="200" alt="Scanner Page" />| <img src="Application_Screenshots/Profile_Page.jpg" width="200" alt="Profile Page" /> |

| Chili Pepper Details| Prediction Result |
|-----------------|------------------------------------|
|  <img src="Application_Screenshots/Chili_pepper_Class_Details01.jpg" width="175" alt="Details 1" /> <img src="Application_Screenshots/Chili_pepper_Class_Details02.jpg" width="175" alt="Details 2" /> | <img src="Application_Screenshots/Prediction_Result01.jpg" width="175" alt="Prediction Result 1" /> <img src="Application_Screenshots/Prediction_Result02.jpg" width="175" alt="Prediction Result 2" /> |

| Navigation Drawer | History Page & History Prediction View | Analytics Page |
|-----------------------|----------------------|----------------------|
| <img src="Application_Screenshots/Darwer.jpg" width="175" alt="Drawer" /> | <img src="Application_Screenshots/History_Page.jpg" width="175" alt="History Page" /> <img src="Application_Screenshots/History_Detailed.jpg" width="175" alt="History Detailed View" /> | <img src="Application_Screenshots/Analytics_Page.jpg" width="175" alt="Analytics Page" /> |

|  Chili Pepper List & Full Description |
|-----------------------|
|<img src="Application_Screenshots/Class_Pepper_List_Page.jpg" width="200" alt="List" /> <img src="Application_Screenshots/Classe_Peppe_Full_Description.jpg" width="200" alt="Full Description" /> |

## 🌶️ Chili Pepper Varieties

| Class Pepper | Preview | Description |
|--------------|---------|------------|
| Anaheim | <img src="Chili_pepper_Classes_Image/Anaheim.png" width="100" alt="Anaheim" /> | Mild chili with a slightly sweet flavor, often used in Mexican dishes. |
| Bird's Eye Chili | <img src="Chili_pepper_Classes_Image/Bird_s Eye Chili.jpg" width="100" alt="Bird's Eye Chili" /> | Small and extremely hot chili, common in Southeast Asian cuisine. |
| Carolina Reaper | <img src="Chili_pepper_Classes_Image/Carolina reaper.jpg" width="100" alt="Carolina Reaper" /> | One of the hottest peppers in the world, fruity and spicy. |
| Cayenne | <img src="Chili_pepper_Classes_Image/Cayenne.jpg" width="100" alt="Cayenne" /> | Medium-hot chili, used dried or powdered in cooking. |
| Ghost Pepper | <img src="Chili_pepper_Classes_Image/Ghost_Pepper.jpg" width="100" alt="Ghost Pepper" /> | Extremely hot chili, also known as Bhut Jolokia. |
| Habanero | <img src="Chili_pepper_Classes_Image/Habanero.png" width="100" alt="Habanero" /> | Very hot chili, fruity flavor, popular in hot sauces. |
| Jalapeno | <img src="Chili_pepper_Classes_Image/Jalapeno.jpg" width="100" alt="Jalapeno" /> | Mild to medium heat, widely used in Mexican cuisine. |
| Poblano | <img src="Chili_pepper_Classes_Image/Poblano.png" width="100" alt="Poblano" /> | Mild chili, often roasted and used in sauces and stuffing. |
| Serrano | <img src="Chili_pepper_Classes_Image/Serrano.png" width="100" alt="Serrano" /> | Medium-hot chili, sharper than jalapeno, used in salsas. |
| Thai Chili | <img src="Chili_pepper_Classes_Image/Thai Chili.png" width="100" alt="Thai Chili" /> | Small, very hot chili, common in Thai cuisine. |







## 📂 Highlighted Projects
| Project | Description |
|--------|-------------|
| **Example-of-Git-and-Github** | Starter repo for Git/GitHub basics — version control, branching, committing. |
| **Umpad_IT200_Act1** | Python project — exercises and assignments. |
| **Umpad_IT108_Activities** | School activities/projects in different languages. |
| **Flutter_Widget_UIComponents** | Flutter UI components showcase. |
| **Pick-and-Match-** | CSS project — styling & responsive design practice. |
| **Flutter_Projects** | Flutter & Dart experiments. |




<h3>Profile Stats</h3><!-- First row: 2 images -->
<p float="left">
  <img src="https://github-readme-streak-stats.herokuapp.com?user=jerwil445&theme=vue-dark" alt="jerwil445 streak badge" width="40%" style="margin-right:4%" />
  <img src="http://github-profile-summary-cards.vercel.app/api/cards/profile-details?username=jerwil445&theme=github_dark" alt="Profile details badge" width="56%" />
</p>

<!-- Second row: 3 images -->
<p float="left" style="margin-top:10px;">
  <img src="http://github-profile-summary-cards.vercel.app/api/cards/most-commit-language?username=jerwil445&theme=gruvbox" alt="Top languages by commit badge" width="32%" style="margin-right:2%" />
  <img src="http://github-profile-summary-cards.vercel.app/api/cards/stats?username=jerwil445&theme=solarized_dark" alt="General stats badge" width="32%" style="margin-right:2%" />
  <img src="http://github-profile-summary-cards.vercel.app/api/cards/productive-time?username=jerwil445&theme=github_dark&utcOffset=8" alt="Commits per day badge" width="32%" />
</p>

<!-- <picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jerwil445/jerwil445/output/pacman-contribution-graph-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jerwil445/jerwil445/output/pacman-contribution-graph.svg">
  <img alt="pacman contribution graph" src="https://raw.githubusercontent.com/jerwil445/jerwil445/output/pacman-contribution-graph.svg">
</picture> -->
