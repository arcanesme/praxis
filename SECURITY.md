# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 3.x     | Yes       |
| < 3.0   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability in Praxis, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, email **jeffreyattoh@reddogsme.com** with:

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if any)

You should receive a response within 72 hours. Critical vulnerabilities will be patched and released within 7 days of confirmation.

## Security Measures

- All GitHub Actions are pinned to full commit SHAs
- Secret scanning with push protection is enabled
- Dependabot monitors dependencies for known vulnerabilities
- CodeQL runs static analysis on every push and PR
- npm packages are published with provenance signing
