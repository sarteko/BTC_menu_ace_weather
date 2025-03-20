# 🌦️ Weather & Time Management Script  
**Credit:** **ArTeK** & **Cruiser**  

---

## 🔧 Guide to Activating and Using the Weather and Time Script

![withcell](https://github.com/user-attachments/assets/eb09d848-b06c-48ed-8a88-ad0a372ae609)

---

### 1. 📝 **Introduction to the System**

- Activates ACE menu which allows you to change the weather and time in the game.
- Currently, the system is in an **immature version**, so some features may require further development.

---

### 2. ⚙️ **Function of the OBJ_weather_set.sqf File**

- The **OBJ_weather_set.sqf** file manages the **"time_sector"** variable and all settings related to weather and time.
- This script allows users to dynamically modify atmospheric conditions during the mission via the **ACE menu Weather / Time menu**.

---

### 3. 🔑 **How to Enable the Script in the Mission**

- The **"time_sector"** variable is used to enable the **ACE menu Weather / Time menu** which allows you to change the weather and time in the game. It should be inserted into the variable name of the desired object.
- The ACE_Callphone is set to enable the **ACE menu Weather / Time menu** if it is present in the player's inventory; if it is not present, the weather functions will not be active. In case you are far from the object set to activate the function, this phone can be conveniently carried with you to view the menu in question.
- To properly activate the script, add the following commands to the **init.sqf** file of the mission:

[] execVM "weather\weather_set.sqf";

[] execVM "weather\OBJ_weather_set.sqf";


- This ensures that the script is executed at mission startup, enabling dynamic weather and time management.

---

### 4. 🎮 **Interacting with the Menu**

- Once the script is active, players can interact with the **ACE menu** to modify weather conditions during the mission.
- Changes to the weather and time will occur in **real-time**, ensuring flexible and immediate control.

---

### 5. 🚀 **Future Developments**

- The current version is still under development, and new features may be added to improve the weather and time management experience.

---

**Variable Name:** `time_sector`

![setnamevarobjet](https://github.com/user-attachments/assets/60dd100f-5b4a-414d-9aed-3e96df03c6d9)


---

## 📺 **Visual Previews**

### Live Monitor
![monitor](https://github.com/user-attachments/assets/4037fb79-3d5d-4bd1-b86e-855fef5ea8c9)

### Device Overview
![device](https://github.com/user-attachments/assets/9ccbecc9-168f-4fe4-a4c0-59a137490c6d)

#### Without ACE_Callphone
![withoutcell](https://github.com/user-attachments/assets/ecc9f1d4-f546-4397-9cfe-31f3f6b6794b)

#### With ACE_Callphone
![withcell](https://github.com/user-attachments/assets/af47a3bb-c0eb-4146-ab7d-dbc1fcfcc0fb)

---
