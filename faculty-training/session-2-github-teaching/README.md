# Session 2: Hands-On GitHub in Teaching

> **Time**: 10:45 AM – 12:00 PM (1 hour 15 minutes)  
> **Format**: Live Demos + Hands-On Lab  
> **Goal**: Create your first GitHub Classroom assignment

## 🎯 Learning Objectives

By the end of this session, you will:
- [ ] Understand how GitHub Classroom works
- [ ] Create a GitHub Classroom assignment from scratch
- [ ] Set up a starter repository with autograding
- [ ] Launch a Codespace for zero-setup development
- [ ] Configure GitHub Actions for automated testing

## 📋 Session Overview

### Part 1: Live Demos (30 minutes)
- GitHub Classroom walkthrough
- Creating assignments and distributing to students
- GitHub Codespaces instant environments
- GitHub Actions for CI/CD

### Part 2: Hands-On Lab (45 minutes)
- Build your first assignment
- Add starter code and tests
- Configure autograding
- Test the student experience

## 🛠️ Tools You'll Use (All Free)

- **GitHub Classroom**: Assignment distribution and autograding
- **GitHub Codespaces**: Cloud development environment
- **GitHub Actions**: Automated testing and CI
- **VS Code / vscode.dev**: Code editing

## 📚 Part 1: Live Demos

### Demo 1: GitHub Classroom Basics

#### What is GitHub Classroom?

GitHub Classroom helps you:
- Distribute assignments as Git repositories
- Give each student their own private repo
- Automate testing and grading
- Track student progress
- Provide feedback via code review

#### Key Concepts

**Assignment Types**:
1. **Individual**: Each student gets their own repo
2. **Group**: Teams share a repo (auto-creates teams)

**Starter Code**:
- Template repository with initial files
- Students start with working code
- Can include tests, documentation, CI config

**Autograding**:
- Run tests automatically on push
- Award points based on test results
- Students see instant feedback
- Reduces manual grading time

#### Demo: Creating a Classroom

1. Go to [classroom.github.com](https://classroom.github.com)
2. Click "New classroom"
3. Select your organization (or create one)
4. Add roster (optional - can import from LMS)
5. Invite TAs as admins

**Organization Setup**:
- Use your institution's GitHub org (if available)
- Or create a new org: `[university]-[course]-[semester]`
- Example: `stanford-cs101-fall2024`

---

### Demo 2: Creating Your First Assignment

#### Step-by-Step Process

**Step 1: Create Template Repository**
```bash
# This is what you prepare once
my-assignment-template/
├── README.md              # Instructions for students
├── src/
│   ├── main.py           # Starter code (partially complete)
│   └── utils.py          # Helper functions
├── tests/
│   ├── test_main.py      # Tests students must pass
│   └── test_utils.py
├── .github/
│   └── workflows/
│       └── classroom.yml # Autograding workflow
└── .gitignore
```

**Step 2: Create Assignment in Classroom**
1. Click "New Assignment"
2. Set assignment name: "Assignment 1: Python Basics"
3. Choose "Individual" or "Group"
4. Set deadline (optional)
5. Select template repository
6. Configure autograding

**Step 3: Configure Autograding**
- Choose test type: Python/Node.js/Java/etc.
- Add test commands
- Set point values
- Configure timeout

Example autograding setup:
```yaml
tests:
  - name: "Test basic functionality"
    setup: "pip install -r requirements.txt"
    run: "pytest tests/test_main.py"
    timeout: 10
    points: 50
  
  - name: "Test edge cases"
    setup: ""
    run: "pytest tests/test_utils.py"
    timeout: 10
    points: 50
```

**Step 4: Share Assignment Link**
- Copy the invitation link
- Share with students via LMS/email
- Students click link → GitHub account → repo created

---

### Demo 3: GitHub Codespaces

#### What is Codespaces?

A complete development environment in the cloud:
- ✅ No local setup required
- ✅ Consistent for all students
- ✅ Pre-configured with dependencies
- ✅ Accessible from any device
- ✅ Free tier for education

#### Creating a Codespace-Ready Assignment

Add a `.devcontainer/devcontainer.json` file:

```json
{
  "name": "Python Assignment Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter"
      ]
    }
  },
  
  "postCreateCommand": "pip install -r requirements.txt",
  
  "forwardPorts": [5000],
  
  "remoteUser": "vscode"
}
```

**Student Experience**:
1. Accept assignment → repo created
2. Click "Code" → "Codespaces" → "Create codespace"
3. Wait 30-60 seconds
4. Full IDE in browser, ready to code!

**Education Benefits**:
- Verified educators get additional free hours
- Students with Student Pack get even more
- Public repos have generous free tier

---

### Demo 4: GitHub Actions for Testing

#### What are GitHub Actions?

Automate tasks when code is pushed:
- Run tests automatically
- Check code style/linting
- Deploy applications
- Generate reports

#### Basic Autograding Workflow

GitHub Classroom creates this automatically:

```yaml
name: Autograding Tests

on:
  push:
    branches: [ main, feedback ]

jobs:
  run-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: pytest tests/ -v
    
    - name: Autograding Reporter
      uses: education/autograding-grading-reporter@v1
```

**Student View**:
- Push code → Actions run automatically
- See green checkmark ✓ if tests pass
- See red X ✗ if tests fail
- Click to see which tests failed

---

## 💻 Part 2: Hands-On Lab

### Lab Objective

Create a simple programming assignment with:
- Starter code
- Automated tests
- Codespaces environment
- Autograding

### Lab Setup

#### Choose Your Language

Pick one to work with during the lab:
- **Python**: Great for beginners, data science
- **JavaScript/Node.js**: Web development, full-stack
- **Java**: Object-oriented, Android, enterprise

We'll use **Python** in the examples, but adapt to your preference.

---

### Step 1: Create Template Repository (15 min)

#### 1.1 Create New Repository

Go to GitHub → New Repository
- Name: `[course]-assignment-1-template`
- Description: "Template for Assignment 1"
- **Important**: Check "Template repository"
- Public or Private (your choice)
- Add README

#### 1.2 Add Starter Code

Create this structure:

```
assignment-1-template/
├── README.md
├── requirements.txt
├── src/
│   └── calculator.py
└── tests/
    └── test_calculator.py
```

**README.md**:
```markdown
# Assignment 1: Simple Calculator

## Objective
Implement basic calculator functions with error handling.

## Tasks
1. Complete the `add()` function
2. Complete the `subtract()` function  
3. Complete the `multiply()` function
4. Complete the `divide()` function (handle division by zero!)

## Running Tests Locally
```bash
pip install -r requirements.txt
pytest tests/ -v
```

## Submission
Push your code to the main branch. Tests will run automatically.
```

**requirements.txt**:
```
pytest>=7.0.0
```

**src/calculator.py** (starter code - partially complete):
```python
"""
Simple calculator module.
Complete the functions below.
"""

def add(a, b):
    """Add two numbers."""
    # TODO: Implement this function
    pass

def subtract(a, b):
    """Subtract b from a."""
    # TODO: Implement this function
    pass

def multiply(a, b):
    """Multiply two numbers."""
    return a * b  # Example: this one is done for you

def divide(a, b):
    """
    Divide a by b.
    Raises:
        ValueError: If b is zero
    """
    # TODO: Implement with error handling
    pass
```

**tests/test_calculator.py**:
```python
"""Tests for calculator module."""
import pytest
from src.calculator import add, subtract, multiply, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

def test_subtract():
    assert subtract(5, 3) == 2
    assert subtract(0, 5) == -5
    assert subtract(-3, -3) == 0

def test_multiply():
    assert multiply(2, 3) == 6
    assert multiply(-2, 3) == -6
    assert multiply(0, 5) == 0

def test_divide():
    assert divide(6, 2) == 3
    assert divide(5, 2) == 2.5
    assert divide(-6, 2) == -3

def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(5, 0)
```

#### 1.3 Test Locally

```bash
# Clone your template repo
git clone [your-template-repo-url]
cd [repo-name]

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run tests (they should fail since functions aren't implemented)
pytest tests/ -v
```

**Expected output**: Tests fail for `add`, `subtract`, `divide`

---

### Step 2: Add Codespaces Configuration (10 min)

Create `.devcontainer/devcontainer.json`:

```bash
mkdir .devcontainer
```

**`.devcontainer/devcontainer.json`**:
```json
{
  "name": "Assignment 1 Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance"
      ],
      "settings": {
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.testing.pytestEnabled": true
      }
    }
  },
  
  "postCreateCommand": "pip install -r requirements.txt"
}
```

Commit and push:
```bash
git add .devcontainer/
git commit -m "Add Codespaces configuration"
git push
```

Test: Go to your repo → Code → Codespaces → Create codespace

---

### Step 3: Create GitHub Classroom Assignment (10 min)

#### 3.1 Create Classroom (if you haven't)
1. Go to [classroom.github.com](https://classroom.github.com)
2. New Classroom → Select/create organization
3. Name it: `[YourName]-FacultyTraining`

#### 3.2 Create Assignment
1. Click "New Assignment"
2. **Title**: "Assignment 1: Simple Calculator"
3. **Type**: Individual
4. **Deadline**: Optional (set to end of day)
5. **Starter code**: Select your template repository
6. **Editor**: Enable Codespaces
7. Click "Continue"

#### 3.3 Configure Autograding
1. Click "Add test"
2. **Test name**: "Calculator Tests"
3. **Setup command**: `pip install -r requirements.txt`
4. **Run command**: `pytest tests/ -v`
5. **Timeout**: 10 minutes
6. **Points**: 100
7. Click "Save"

#### 3.4 Create Assignment
Click "Create assignment"

You'll get an invitation link like:
`https://classroom.github.com/a/abc123xyz`

---

### Step 4: Test Student Experience (10 min)

#### Simulate Being a Student

1. **Open invitation link** (in incognito/private browsing)
2. **Accept assignment** → Repo created
3. **Open Codespace**:
   - Click "Code" → "Codespaces"
   - Click "Create codespace on main"
   - Wait for environment to load
4. **Complete one function**:
   ```python
   def add(a, b):
       """Add two numbers."""
       return a + b
   ```
5. **Run tests in terminal**:
   ```bash
   pytest tests/ -v
   ```
6. **Commit and push**:
   ```bash
   git add src/calculator.py
   git commit -m "Implement add function"
   git push
   ```
7. **Check Actions tab** → See autograding run

#### What Students See

- ✅ Green checkmark: Tests passed!
- ✗ Red X: Tests failed (click to see details)
- 🟡 Yellow circle: Tests running

---

## 🎉 Deliverable

By the end of this session, you have:

✅ **A template repository** with:
- Starter code
- Tests
- Codespaces configuration
- README instructions

✅ **A GitHub Classroom assignment** with:
- Assignment created
- Autograding configured
- Invitation link ready

✅ **Tested student experience**:
- Accepting assignment
- Using Codespaces
- Submitting work
- Seeing test results

---

## 📊 Discussion Questions

### For Reflection (5 minutes)

1. **How could you adapt this for your course?**
   - What assignment would you convert first?
   - What language/framework would you use?

2. **What challenges do you anticipate?**
   - Student access to GitHub?
   - Learning curve for Git?
   - Existing course infrastructure?

3. **What excites you about this approach?**
   - Automated feedback?
   - Real-world tools?
   - Scalability?

---

## 💡 Tips & Best Practices

### For Students

✅ **Do**:
- Make template repos with working examples
- Test your autograding thoroughly
- Provide clear README instructions
- Use Codespaces to eliminate setup issues
- Give partial credit via multiple tests

❌ **Avoid**:
- Vague assignment requirements
- Overly complex starter code
- All-or-nothing grading
- Missing documentation
- Untested autograding

### Common Issues

**Issue**: Students can't see test results
- **Fix**: Make sure feedback branch exists in template

**Issue**: Codespaces quota exceeded
- **Fix**: Apply for education benefits, use public repos

**Issue**: Tests pass locally but fail in CI
- **Fix**: Check for hardcoded paths, environment differences

**Issue**: Students push but Actions don't run
- **Fix**: Check Actions are enabled in repo settings

---

## 🔗 Resources

### Documentation
- [GitHub Classroom Docs](https://docs.github.com/en/education/manage-coursework-with-github-classroom)
- [Codespaces Docs](https://docs.github.com/en/codespaces)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

### Example Assignments
- [GitHub Classroom Examples](https://github.com/education/classroom-examples)
- [Autograding Examples](https://github.com/education/autograding-example-python)

### Getting Help
- [GitHub Education Community](https://github.com/education/community)
- [GitHub Campus Advisors](https://education.github.com/teachers)

---

## ⏭️ Next Session

**Session 3: Copilot for Learning**
- How to use GitHub Copilot in assignments
- Teaching students to use AI responsibly
- Creating Copilot-aware assignment briefs

---

**Questions?** Ask during the session or in the discussion forum!

**Need help?** Office hours after training or join faculty community discussions.
