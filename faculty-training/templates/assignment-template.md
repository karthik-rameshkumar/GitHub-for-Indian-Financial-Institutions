# Assignment Template: [Assignment Name]

> **Course**: [Course Name]  
> **Due Date**: [Date and Time]  
> **Points**: [Total Points]  
> **Type**: Individual / Pair / Team

## 📋 Overview

[Brief description of what students will build/implement/learn in this assignment]

### Learning Objectives

By completing this assignment, you will:
- [ ] [Learning objective 1]
- [ ] [Learning objective 2]
- [ ] [Learning objective 3]
- [ ] [Learning objective 4]

### Prerequisites

Before starting, you should be familiar with:
- [Prerequisite skill/concept 1]
- [Prerequisite skill/concept 2]
- [Prerequisite skill/concept 3]

---

## 🎯 Assignment Tasks

### Part 1: [Task Category] (XX points)

**Objective**: [What this part accomplishes]

**Requirements**:
1. [Specific requirement 1]
2. [Specific requirement 2]
3. [Specific requirement 3]

**Acceptance Criteria**:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

**Files to Create/Modify**:
- `src/[filename].ext` - [Purpose]
- `tests/[test-file].ext` - [Test requirements]

---

### Part 2: [Task Category] (XX points)

**Objective**: [What this part accomplishes]

**Requirements**:
1. [Specific requirement 1]
2. [Specific requirement 2]

**Acceptance Criteria**:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]

**Files to Create/Modify**:
- `[filename]` - [Purpose]

---

### Part 3: Testing & Quality (XX points)

**Objective**: Ensure your code is reliable and maintainable

**Requirements**:
1. Write tests for all public functions/methods
2. Achieve minimum 75% code coverage
3. All tests must pass (GitHub Actions green)
4. Code must pass linting checks

**Acceptance Criteria**:
- [ ] Test file exists: `tests/[test-file].ext`
- [ ] Coverage report shows ≥75%
- [ ] CI/CD pipeline passes
- [ ] No linting errors

---

### Part 4: Documentation (XX points)

**Objective**: Help others understand your code

**Requirements**:
1. Complete the README.md with all sections
2. Add inline comments for complex logic
3. Write clear commit messages
4. Fill out PR description template

**Acceptance Criteria**:
- [ ] README.md includes: setup, usage, examples
- [ ] Functions/classes have docstrings
- [ ] Commits follow conventional format
- [ ] PR description is complete

---

## 🤖 Using AI Tools

### Permitted AI Use

You **MAY** use GitHub Copilot, ChatGPT, or similar tools for:
- Understanding concepts and syntax
- Generating test cases
- Improving code quality
- Writing documentation

### Required Disclosure

You **MUST** include an "AI Assistance" section in your submission:

```markdown
## AI Assistance Declaration

### Tools Used
- [Tool name]

### How AI Helped
1. **[Feature/File Name]**
   - Prompt: "[What you asked]"
   - Used: [What you took from AI]
   - Changed: [How you modified it]
   - Learned: [What you understand now]

### Reflection
[2-3 sentences about what you learned from AI interaction]
```

### Helpful Prompts for This Assignment

**For Understanding**:
```
"Explain [concept] in the context of [programming language]"
"What's the difference between [approach A] and [approach B]?"
"Walk me through how [algorithm/pattern] works step-by-step"
```

**For Implementation**:
```
"Show me the structure for [feature] without complete implementation"
"What edge cases should I consider for [function]?"
"Help me debug this error: [error message]"
```

**For Testing**:
```
"Generate test cases for [function] including edge cases"
"What scenarios should I test for [feature]?"
"Help me write a test that checks [specific behavior]"
```

**For Documentation**:
```
"Help me write a README section explaining how to [use feature]"
"Generate docstrings for this function: [paste function]"
"Create usage examples for [feature]"
```

---

## 🚀 Getting Started

### 1. Accept the Assignment

Click the GitHub Classroom link provided:
- [GitHub Classroom Assignment Link]

This will create a private repository for you with starter code.

### 2. Clone Your Repository

```bash
git clone [your-repo-url]
cd [repo-name]
```

### 3. Set Up Your Environment

#### Option A: Using GitHub Codespaces (Recommended)
1. Click the "Code" button in your repository
2. Select "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for environment to load (1-2 minutes)

#### Option B: Local Setup
```bash
# Install dependencies
[package-manager] install

# Verify setup
[package-manager] test

# Start development server (if applicable)
[package-manager] start
```

### 4. Review Starter Code

Explore the repository structure:
```
.
├── README.md              # This file
├── src/                   # Your code goes here
│   └── [starter-files]
├── tests/                 # Your tests go here
│   └── [starter-tests]
├── .github/
│   └── workflows/
│       └── ci.yml         # Automated testing
└── [config files]
```

### 5. Create a Development Branch

```bash
git checkout -b develop
```

**Do NOT commit directly to the `main` branch!**

---

## 💻 Development Workflow

### 1. Work in Small Iterations

For each feature:
1. Write tests first (TDD approach)
2. Implement the feature
3. Run tests locally
4. Commit with clear message

### 2. Commit Frequently

Good commit messages:
```bash
git commit -m "feat: add user authentication"
git commit -m "test: add tests for login flow"
git commit -m "fix: handle empty input in parser"
git commit -m "docs: update README with setup instructions"
```

Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New feature
- `fix:` - Bug fix
- `test:` - Test additions
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `style:` - Formatting changes

### 3. Push Regularly

```bash
git push origin develop
```

This triggers GitHub Actions to run tests automatically.

### 4. Check CI Status

- Go to "Actions" tab in your GitHub repository
- Verify tests pass (green checkmark ✓)
- Fix any failures before submitting

---

## ✅ Submission Requirements

### Before Submitting

Complete this checklist:

#### Functionality
- [ ] All requirements from Parts 1-2 are implemented
- [ ] Code runs without errors
- [ ] Meets all acceptance criteria

#### Testing
- [ ] All tests pass locally
- [ ] GitHub Actions CI passes (green)
- [ ] Code coverage ≥75%
- [ ] Edge cases are tested

#### Documentation
- [ ] README.md is complete
- [ ] Code has helpful comments
- [ ] Functions have docstrings
- [ ] AI Assistance section is filled out

#### Git Hygiene
- [ ] Commits are meaningful and atomic
- [ ] Commit messages follow conventions
- [ ] No merge conflicts
- [ ] No unnecessary files committed

### How to Submit

1. **Ensure All Tests Pass**
   ```bash
   [package-manager] test
   ```

2. **Push Final Changes**
   ```bash
   git push origin develop
   ```

3. **Create Pull Request**
   - Go to your repository on GitHub
   - Click "Pull Requests" → "New Pull Request"
   - Base: `main` ← Compare: `develop`
   - Fill out the PR template completely
   - Click "Create Pull Request"

4. **Submit PR Link**
   - Copy your PR URL
   - Submit via [Course LMS/Form]
   - **Deadline**: [Date and Time]

**Your submission is the Pull Request, not just pushing code!**

---

## 📊 Grading Rubric

| Category | Points | Criteria |
|----------|--------|----------|
| **Functionality** | XX | Requirements met, code works correctly |
| **Code Quality** | XX | Clean, readable, follows conventions |
| **Testing** | XX | Comprehensive tests, good coverage, CI passes |
| **Documentation** | XX | Clear README, comments, docstrings |
| **Git Workflow** | XX | Good commits, PR description, collaboration |
| **AI Disclosure** | XX | Complete, thoughtful reflection |
| **TOTAL** | **100** | |

See [detailed rubric](../rubrics/contribution-based.md) for full criteria.

### Extra Credit Opportunities (+5 points each)

- [ ] Exceed coverage requirement (>90%)
- [ ] Add GitHub Actions for additional checks (e.g., linting, security)
- [ ] Create excellent documentation with diagrams/examples
- [ ] Help classmates via PR reviews or issue discussions

---

## 🆘 Getting Help

### Office Hours
- **When**: [Days and times]
- **Where**: [Location/Zoom link]
- **How**: Come with specific questions and code examples

### Discussion Forum
- Post questions in [Forum/Slack/Discord]
- Check FAQ before posting
- Help answer others' questions!

### Debugging Tips

1. **Read error messages carefully**
   - What file and line?
   - What does the error say?

2. **Check GitHub Actions logs**
   - Click on failed check
   - Expand logs to see details
   - Look for specific test failures

3. **Use print debugging**
   - Add print statements
   - Run tests locally
   - Observe output

4. **Ask AI for help**
   - Paste error message
   - Ask for explanation
   - Don't just copy solutions!

### Common Issues

**Issue**: Tests pass locally but fail in CI
- **Solution**: Check for hardcoded paths or environment differences

**Issue**: Coverage is below 75%
- **Solution**: Run coverage report, identify untested code, add tests

**Issue**: Merge conflicts
- **Solution**: Pull main, resolve conflicts, test again, push

---

## 📚 Resources

### Required Reading
- [Resource 1 with link]
- [Resource 2 with link]

### Helpful Tutorials
- [Tutorial 1]
- [Tutorial 2]

### Documentation
- [Official docs for library/framework]
- [API reference]

### Examples
- [Example project or implementation]

---

## 🎯 Learning Tips

### Before You Start
1. Read the entire assignment
2. Sketch out your approach
3. Identify what you don't understand
4. Ask questions early

### While Working
1. Test frequently (after each small change)
2. Commit after each working feature
3. Take breaks to avoid frustration
4. Document as you go

### Using AI Effectively
1. Start with your own attempt
2. Use AI to check understanding
3. Always test AI suggestions
4. Document what you learned

### Time Management
- **Day 1-2**: Understand requirements, set up, start Part 1
- **Day 3-4**: Complete Part 1, start Part 2
- **Day 5-6**: Complete Part 2, write tests
- **Day 7**: Documentation, AI disclosure, final testing
- **Submit**: With time to spare!

---

## ⚖️ Academic Integrity

### Permitted
- Using AI tools with disclosure
- Searching documentation and tutorials
- Asking for help in office hours
- Discussing approaches with classmates

### Not Permitted
- Copying code from classmates
- Sharing your code with others
- Using code from previous semesters without attribution
- Submitting AI-generated code without understanding

**Violation of academic integrity will result in a failing grade.**

---

## 📝 Submission Checklist

Print or save this final checklist:

- [ ] All functionality requirements met
- [ ] All tests pass (locally and in CI)
- [ ] Code coverage ≥75%
- [ ] README.md complete with all sections
- [ ] AI Assistance Declaration filled out
- [ ] Meaningful commit messages throughout
- [ ] Pull Request created and description completed
- [ ] PR link submitted to [LMS/Form]
- [ ] Submitted before deadline: [Date and Time]

**Total checkmarks**: ___/9

Ready to submit? Double-check everything, then create your PR!

---

**Questions?** Ask in [forum/office hours]  
**Due Date**: [Date and Time]  
**Late Policy**: [Your late policy]

Good luck! 🚀

---

*This assignment is part of [Course Name]. For course policies, see the syllabus.*
