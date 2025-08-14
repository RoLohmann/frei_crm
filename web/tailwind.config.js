/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,jsx,md}'],
  theme: {
    extend: {
      fontFamily: { sans: ['Inter','ui-sans-serif','system-ui','Apple Color Emoji','Segoe UI Emoji'] },
      colors: {
        primary: {
          DEFAULT: '#8A05BE',
          50: '#F8ECFF',100:'#F0D9FF',200:'#DFB5FF',300:'#C88CFA',
          400:'#AB5DEB',500:'#8A05BE',600:'#7303A0',700:'#5B0283',800:'#430162',900:'#2E0A40',
        },
        accent: '#B517F4',
      },
      boxShadow: { card: '0 10px 20px rgba(138,5,190,0.08)' },
    },
  },
  plugins: [],
}