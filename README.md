# Eww-Bar

## 📺 Demo

[![Watch the Eww-bar demo on Vimeo](https://i.vimeocdn.com/video/1820848590-0c6f437b29fd146cb22101687d7a3b03867ef7d4c389f6a61c579dc77d2a02cc-d_640)](https://vimeo.com/1092604137)

[Click here to watch on Vimeo](https://vimeo.com/1092604137)


A highly modular and customizable GTK bar for Linux desktops, built using [EWW (ElKowar's Wacky Widgets)](https://elkowar.github.io/eww/) and the Yuck configuration language.

> **Author:** [KhalidWKhedr](https://github.com/KhalidWKhedr)  
> **Repo:** [KhalidWKhedr/Eww-Bar](https://github.com/KhalidWKhedr/Eww-Bar)  
> **Main Languages:** Yuck, SCSS, Shell  
> **License:** _Not specified_  

---

## ✨ Project Highlights

- **Extremely Modular Architecture:**  
  All configurations, widgets, and styles are split into separate, maintainable files. The main files (`eww.yuck` and `eww.scss`) act purely as import roots, cleanly aggregating logic and styles from their respective directories.
- **Easy-to-Extend:**  
  Add, remove, or swap out widgets and components by simply editing the modular files in `yuck/`, `scss/`, or `scripts/` directories.
- **Clean Separation of Concerns:**  
  - **Layout & Logic:** Handled in the Yuck files (`yuck/`)
  - **Styles & Themes:** Modular SCSS styles in `scss/`
  - **Widget Scripts:** Helper scripts in `scripts/`
- **Scalable Design:**  
  New widgets or features can be added with minimal changes to existing code.

---

## 📂 Project Structure

```
eww.yuck           # Root config file, imports all Yuck modules
eww.scss           # Root style file, imports all SCSS modules
/scripts/          # Standalone shell/helper scripts for widgets
/yuck/             # Individual widget/component config files
/scss/             # Individual widget/component style files
/background.jpeg   # Bar background asset
/extra_stuff/      # Optional or experimental content
```

---

## 🚀 Quick Start

1. **Clone the repository:**
   ```sh
   git clone https://github.com/KhalidWKhedr/Eww-Bar.git
   cd Eww-Bar
   ```

2. **Install EWW:**  
   Follow instructions at [EWW's official documentation](https://elkowar.github.io/eww/).

3. **(Optional) Install dependencies:**  
   Certain widgets may require additional CLI tools (e.g., `playerctl`, `acpi`, etc.).

4. **Configure/Customize:**  
   - Add or edit modules in the `yuck/` and `scss/` folders to tailor the bar to your needs.
   - Use the modular structure to easily maintain or extend your bar.

5. **Launch the Bar:**
   ```sh
   eww daemon
   eww open bar
   ```
   (_Or use your preferred method for your window manager._)

---

## 🧩 Extending & Customizing

- **Add a Widget:**  
  1. Create a new `.yuck` file in `yuck/` for your widget logic.
  2. Add a corresponding `.scss` file in `scss/` for styles.
  3. Reference/import your new files in `eww.yuck` and `eww.scss`.

- **Tweak Styles:**  
  Modify or extend the SCSS modules in `scss/` without touching the rest of the codebase.

- **Write Custom Scripts:**  
  Place scripts in `scripts/` and reference them from your widgets for dynamic data.

---

## 🧑‍💻 Contributing

- Clear modular boundaries make it easy for contributors to work on individual widgets, styles, or scripts without interfering with others.
- File/folder structure is self-explanatory; just follow the conventions for new contributions.
- Open issues or submit PRs for enhancements or bug fixes!

---

## 📝 License

_This project currently does not specify a license. Please add one to clarify usage and contributions._

---

## 🌟 Why Eww-Bar Stands Out

- **Pure import logic:**  
  The root config and style files (`eww.yuck` and `eww.scss`) are kept minimal, serving only to aggregate and import modular components.
- **Effortless scalability:**  
  The modular system ensures you never have to touch monolithic files—add or change features in isolation.
- **Ideal for both beginners and advanced users:**  
  Newcomers can swap out pre-made widgets; advanced users can create their own modules with ease.

---

**Ready to build your dream Linux bar? Start modular. Start with Eww-Bar!**
