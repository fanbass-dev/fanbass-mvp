// tailwind.config.js
module.exports = {
  darkMode: 'class',
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        surface: '#03050e',
        brand: '#5865F2', // Discord-ish
        primary: '#1e1e2f',
        secondary: '#3b3b55',
        accent: '#7f5af0',
        subtle: '#9ca3af',
      },
      borderColor: {
        DEFAULT: '#444',
      },
      fontSize: {
        'xs': '.75rem',
        'sm': '.875rem',
        'base': '1rem',
        'md': '1.1rem',
        'lg': '1.25rem',
      },
    },
  },
  plugins: [],
}
