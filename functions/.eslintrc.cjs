module.exports = {
  extends: [
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  overrides: [
    {
      files: ["*.js", "*.jsx"],
     rules: {
         "@typescript-eslint/no-unused-vars": "off",
         "@typescript-eslint/no-unused-expressions": [
           "error",
           {
             allowShortCircuit: true, // 이 옵션을 필요에 따라 활성화하거나 비활성화
             allowTernary: true
           }
         ]

       }
    }
  ],
  parserOptions: {
    ecmaVersion: "latest"
  },
  env: {
    es6: true
  }
};