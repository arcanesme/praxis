module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', ['feat', 'fix', 'refactor', 'test', 'docs', 'chore', 'ci', 'perf', 'style', 'build', 'revert']],
    'scope-empty': [1, 'never'],
    'subject-max-length': [2, 'always', 72],
    'body-max-line-length': [2, 'always', 100],
    'subject-case': [2, 'always', 'lower-case'],
  }
};
