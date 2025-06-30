# Contributing to GitHub for Indian Financial Institutions

We welcome contributions from the financial services community! This repository aims to provide best practices, templates, and examples for Indian financial institutions implementing DevSecOps with GitHub.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## How to Contribute

### Reporting Issues

- **Security Vulnerabilities**: Please report security issues privately to security@financial-org.com
- **Bugs**: Use GitHub Issues with the "bug" label
- **Feature Requests**: Use GitHub Issues with the "enhancement" label
- **Documentation**: Use GitHub Issues with the "documentation" label

### Development Process

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/GitHub-for-Indian-Financial-Institutions.git
   cd GitHub-for-Indian-Financial-Institutions
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow our coding standards and best practices
   - Include appropriate tests
   - Update documentation as needed

4. **Test Your Changes**
   ```bash
   # For workflow changes
   act -j test-workflow
   
   # For documentation changes
   markdownlint README.md docs/
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new compliance template for IRDAI"
   ```

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Contribution Guidelines

### Types of Contributions

1. **CI/CD Pipeline Improvements**
   - New workflow templates
   - Security scanning enhancements
   - Performance optimizations

2. **Documentation**
   - Best practices guides
   - Implementation tutorials
   - Compliance documentation

3. **Example Applications**
   - BFSI-specific applications
   - Integration examples
   - Security implementations

4. **Templates and Configurations**
   - Branch protection rules
   - Security policies
   - Deployment configurations

### Coding Standards

#### GitHub Actions Workflows

```yaml
# Use consistent naming
name: Descriptive Workflow Name

# Include appropriate triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# Use environment variables for configuration
env:
  NODE_VERSION: '18'
  
jobs:
  # Use descriptive job names
  build-and-test:
    name: Build and Test Application
    runs-on: ubuntu-latest
    
    steps:
    # Use specific action versions
    - name: Checkout code
      uses: actions/checkout@v4
      
    # Include meaningful step names
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
```

#### Documentation

- Use clear, concise language
- Include code examples where appropriate
- Follow markdown standards
- Include table of contents for long documents
- Use consistent heading structure

#### Example Applications

- Include comprehensive README.md
- Provide Docker configuration
- Include security best practices
- Add monitoring and logging
- Include test coverage

### Pull Request Guidelines

1. **Title Format**
   ```
   type(scope): description
   
   Examples:
   feat(workflows): add IRDAI compliance pipeline
   fix(docs): correct NBFC setup instructions
   docs(security): add secrets management guide
   ```

2. **Description Template**
   ```markdown
   ## Changes Made
   - Brief description of changes
   - List key modifications
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Security enhancement
   
   ## Compliance Considerations
   - [ ] RBI guidelines reviewed
   - [ ] IRDAI requirements considered
   - [ ] Security implications assessed
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests verified
   - [ ] Security scans passed
   
   ## Checklist
   - [ ] Code follows project standards
   - [ ] Documentation updated
   - [ ] No sensitive data included
   - [ ] Compliance requirements met
   ```

3. **Review Process**
   - All PRs require at least 2 approvals
   - Security team review for security-related changes
   - Compliance officer review for regulatory changes
   - Automated checks must pass

### Sensitive Information Guidelines

⚠️ **NEVER commit sensitive information:**

- API keys or tokens
- Database passwords
- Private keys or certificates
- Customer data or PII
- Internal system details
- Proprietary algorithms

Use the following instead:
- GitHub Secrets for sensitive values
- Environment variables
- Configuration templates
- Example/dummy data

### Financial Services Considerations

When contributing to this repository, consider:

1. **Regulatory Compliance**
   - Ensure changes comply with RBI/IRDAI guidelines
   - Document compliance implications
   - Include regulatory references

2. **Security Standards**
   - Follow OWASP best practices
   - Implement defense in depth
   - Include security testing

3. **Data Protection**
   - Implement data encryption
   - Follow data localization requirements
   - Include audit trails

4. **Operational Resilience**
   - Design for high availability
   - Include disaster recovery considerations
   - Plan for business continuity

## Development Setup

### Prerequisites

- Git 2.30+
- Docker 20.10+
- Node.js 18+ (for documentation site)
- Python 3.11+ (for scripts)

### Local Development

1. **Clone Repository**
   ```bash
   git clone https://github.com/karthik-rameshkumar/GitHub-for-Indian-Financial-Institutions.git
   cd GitHub-for-Indian-Financial-Institutions
   ```

2. **Install Dependencies**
   ```bash
   # For documentation
   npm install
   
   # For Python scripts
   pip install -r requirements-dev.txt
   ```

3. **Run Tests**
   ```bash
   # Test workflows
   act --list
   
   # Lint documentation
   npm run lint
   
   # Test Python scripts
   pytest tests/
   ```

4. **Preview Documentation**
   ```bash
   npm run serve
   ```

### Testing Workflows

Use [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test a specific workflow
act -j build-and-test

# Test with secrets
act -s GITHUB_TOKEN=your_token
```

## Review Process

### Automated Checks

All pull requests run through automated checks:

1. **Lint Checks**
   - Markdown linting
   - YAML validation
   - Workflow syntax verification

2. **Security Scans**
   - Secret detection
   - Dependency vulnerability scanning
   - Configuration security review

3. **Compliance Validation**
   - Regulatory requirement checks
   - Best practice validation
   - Documentation completeness

### Manual Review

Pull requests require manual review from:

1. **Code Owners** (required)
   - Technical accuracy
   - Implementation quality
   - Documentation completeness

2. **Security Team** (for security changes)
   - Security implications
   - Threat model validation
   - Compliance considerations

3. **Subject Matter Experts** (domain-specific)
   - Financial services expertise
   - Regulatory knowledge
   - Industry best practices

## Community

### Communication Channels

- **GitHub Discussions**: General questions and community discussions
- **GitHub Issues**: Bug reports and feature requests
- **Email**: security@financial-org.com for security-related matters

### Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Community acknowledgments

## License

By contributing to this repository, you agree that your contributions will be licensed under the MIT License.

## Getting Help

If you need help with:

1. **Technical Issues**
   - Check existing GitHub Issues
   - Create a new issue with details
   - Join GitHub Discussions

2. **Security Questions**
   - Email security@financial-org.com
   - Do not post security issues publicly

3. **Compliance Questions**
   - Review existing documentation
   - Consult with compliance team
   - Refer to regulatory guidelines

Thank you for contributing to the financial services open source community!