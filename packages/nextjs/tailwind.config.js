/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}", "./utils/**/*.{js,ts,jsx,tsx}"],
  plugins: [require("daisyui")],
  darkTheme: "dark",
  darkMode: ["selector", "[data-theme='dark']"],
  // DaisyUI theme colors
  daisyui: {
    themes: [
      {
        light: {
          primary: "#919191",
          "primary-content": "#000000",
          secondary: "#D2D0CB",
          "secondary-content": "#000000",
          accent: "#919191",
          "accent-content": "#000000",
          neutral: "#000000",
          "neutral-content": "#ffffff",
          "base-100": "#ffffff",
          "base-200": "#FFFFFF",
          "base-300": "#D2D0CB",
          "base-content": "#000000",
          info: "#919191",
          success: "#34EEB6",
          warning: "#FFCF72",
          error: "#FF8863",

          "--rounded-btn": "9999rem",

          ".tooltip": {
            "--tooltip-tail": "6px",
          },
          ".link": {
            textUnderlineOffset: "2px",
          },
          ".link:hover": {
            opacity: "80%",
          },
        },
      },
      {
        dark: {
          primary: "#000000",
          "primary-content": "#FFFFFF",
          secondary: "#000000",
          "secondary-content": "#FFFFFF",
          accent: "#222222",
          "accent-content": "#FFFFFF",
          neutral: "#FFFFFF",
          "neutral-content": "#222222",
          "base-100": "#222222",
          "base-200": "#000000",
          "base-300": "#000000",
          "base-content": "#FFFFFF",
          info: "#222222",
          success: "#34EEB6",
          warning: "#FFCF72",
          error: "#FF8863",

          "--rounded-btn": "9999rem",

          ".tooltip": {
            "--tooltip-tail": "6px",
            "--tooltip-color": "oklch(var(--p))",
          },
          ".link": {
            textUnderlineOffset: "2px",
          },
          ".link:hover": {
            opacity: "80%",
          },
        },
      },
    ],
  },
  theme: {
    colors: {
      chartreuse: "#DFFE00",
      "battleship-gray": "#919191",
      timberwolf: "#D2D0CB",
      white: "#FFFFFF",
      black: "#000000",
    },
    extend: {
      boxShadow: {
        center: "0 0 12px -2px rgb(0 0 0 / 0.05)",
      },
      animation: {
        "pulse-fast": "pulse 1s cubic-bezier(0.4, 0, 0.6, 1) infinite",
      },
    },
  },
};
