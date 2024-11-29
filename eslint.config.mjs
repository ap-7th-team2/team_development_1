import globals from 'globals';
import pluginJs from '@eslint/js';
import prettierPlugin from 'eslint-plugin-prettier';
import prettierConfig from 'eslint-config-prettier';

/** @type {import('eslint').Linter.Config[]} */
export default [
  {
    // files: ['views/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
  },
  pluginJs.configs.recommended,
  {
    plugins: {
      prettier: prettierPlugin,
    },
    rules: {
      ...prettierConfig.rules,
      'prettier/prettier': 'error',
      quotes: ['error', 'single'],
      semi: ['error', 'always'],
      indent: ['error', 2],
      'comma-dangle': ['error', 'always-multiline'],
    },
  },
];
