# darkly - Security Audit Tool

Web security vulnerability scanner and analyzer for educational purposes.

## Features

- XSS (Cross-Site Scripting) detection
- SQL Injection detection
- Path Traversal detection
- Sensitive data exposure scanning
- Security header analysis
- Cookie security checking
- URL security analysis
- Password strength checker
- Hash type identification

## Usage

```bash
python3 darkly.py              # Run demo
python3 darkly.py file.txt     # Analyze file
```

## Vulnerability Detection

### XSS Detection
Detects patterns like:
- `<script>` tags
- Event handlers (onclick, onerror)
- JavaScript URIs
- DOM manipulation

### SQL Injection
Detects patterns like:
- SQL keywords (SELECT, INSERT, UPDATE, DELETE)
- Logic bypasses (OR 1=1)
- UNION attacks
- Comment injection

### Sensitive Data
Scans for:
- API keys
- AWS credentials
- Passwords in URLs
- Private keys
- Credit card numbers
- JWT tokens

### Security Headers
Checks for:
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- X-XSS-Protection
- Referrer-Policy

## API Usage

```python
from darkly import SecurityAnalyzer, Vulnerability

analyzer = SecurityAnalyzer()

# Check content for XSS
vulns = analyzer.check_xss(html_content, "page.html")

# Check for SQL injection
vulns = analyzer.check_sqli(query, "input")

# Check security headers
vulns = analyzer.check_security_headers(headers, "api.example.com")

# Check password strength
score, issues = analyzer.check_password_strength("password123")

# Identify hash type
hash_type = analyzer.identify_hash("5d41402abc4b2a76b9719d911017c592")

# Generate report
print(analyzer.generate_report())
```

## Vulnerability Severity

| Level | Description |
|-------|-------------|
| CRITICAL | Immediate action required |
| HIGH | Significant risk |
| MEDIUM | Moderate risk |
| LOW | Minor concern |

## Disclaimer

This tool is for educational and authorized security testing only. Always obtain proper authorization before testing any systems you do not own.

## Author

Implementation for 42 curriculum (security track).
