// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {},
    colors: {
      "blue": "#4169B2",
      "blue-dark": "#2C4676",
      "blue-grey": "#44526C",
      "blue-grey-light": "#97A5BF",
      "sky-blue": "#BDD4FF",
      "sky-blue-light": "#D7E4FE",
      "blue-white": "#E9EDF3",
      "white": "#FFFFFF",
      "off-white": "#FAFAFA",
      "yellow": "#F4B206",
      "yellow-dark": "#897541",
      "yellow-med": "#AD7D02",
      "yellow-light": "#FFD25E",
      "yellow-pale": "#FFE7AA",
      "yellow-white": "#FFFCF4",
      "black": "#333333",
      "grey": "#33333380"

    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
