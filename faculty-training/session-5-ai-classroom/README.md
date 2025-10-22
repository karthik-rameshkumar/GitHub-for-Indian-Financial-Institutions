# Session 5: Build the AI-Powered Classroom

> **Time**: 3:30 PM – 4:30 PM (1 hour)  
> **Format**: Hands-On Build Sprint  
> **Goal**: Create a ready-to-run AI-integrated lab

## 🎯 Learning Objectives

By the end of this session, you will:
- [ ] Implement your assignment designs from earlier sessions
- [ ] Create a complete GitHub Classroom assignment with autograding
- [ ] Set up Codespaces for zero-configuration development
- [ ] Configure GitHub Actions for automated testing
- [ ] Build a comprehensive rubric with AI disclosure criteria
- [ ] Have a ready-to-deploy assignment for your course

## 📋 Session Overview

### Structure: Choose Your Own Adventure

This is a **build sprint** where you choose what to create based on your priorities:

**Option A**: Turn an existing lab into Classroom + Codespaces assignment (45 min)  
**Option B**: Add GitHub Actions for automated testing to existing assignment (30 min)  
**Option C**: Create a comprehensive rubric with AI disclosure (30 min)  
**Option D**: Build a new assignment from scratch (60 min)

Most faculty will choose **Option A** or a combination approach.

---

## 🛠️ Zero-Cost Tools Stack Reference

**Quick reminder of what's available** (all free):

### Core GitHub (Free)
- **GitHub**: Repositories, issues, PRs, Projects, Discussions
- **GitHub Classroom**: Assignment distribution, autograding
- **GitHub Actions**: CI/CD on public repos
- **GitHub Codespaces**: Education quota + public repo usage
- **github.dev / vscode.dev**: In-browser IDE

### AI & Development (Free/Educational)
- **GitHub Copilot**: Free for verified educators
- **VS Code**: Desktop IDE (free)
- **Microsoft Copilot** (web): Brainstorming and drafting

### Student Developer Pack (Verify Availability)
- **JetBrains IDEs**: Professional tools (edu license)
- **Canva Pro**: Design and presentations (edu access)
- **MongoDB Atlas**: Database hosting (free tier)
- **Notion**: Documentation and wikis (edu plan)

### Data & ML (Free)
- **Kaggle Notebooks**: Data science environment
- **Google Colab**: Python notebooks
- **Hugging Face**: Models and datasets

---

## 🚀 Option A: Complete Classroom Assignment (Recommended)

**Time**: 45-60 minutes  
**Outcome**: Ready-to-deploy assignment with autograding and Codespaces

### Step-by-Step Build Guide

#### Step 1: Set Up Template Repository (10 min)

**Create New Repository**:
```bash
# On GitHub:
# 1. Click "New Repository"
# 2. Name: [course-code]-[assignment-name]-template
# 3. Description: "Template for [Assignment Name]"
# 4. Check "Template repository" ✓
# 5. Add README
# 6. Choose Public or Private
```

**Add Basic Structure**:
```
your-assignment-template/
├── README.md              # Student instructions
├── .gitignore            # Exclude build artifacts
├── requirements.txt       # Dependencies (Python)
│   or package.json        # Dependencies (Node.js)
│   or pom.xml            # Dependencies (Java)
├── .devcontainer/
│   └── devcontainer.json # Codespaces config
├── .github/
│   └── workflows/
│       └── classroom.yml  # Autograding
├── src/                   # Student code here
│   └── [starter files]
└── tests/                 # Test suite
    └── [test files]
```

---

#### Step 2: Add Starter Code (10 min)

**Choose your language** (examples below for Python, adapt as needed):

**src/calculator.py** (starter code - partially complete):
```python
"""
Assignment: Simple Calculator
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
    # EXAMPLE: This one is done for you
    return a * b

def divide(a, b):
    """
    Divide a by b.
    
    Args:
        a: numerator
        b: denominator
    
    Returns:
        float: result of division
    
    Raises:
        ValueError: if b is zero
    """
    # TODO: Implement with error handling
    pass
```

**requirements.txt**:
```
pytest>=7.0.0
pytest-cov>=4.0.0
```

---

#### Step 3: Add Test Suite (10 min)

**tests/test_calculator.py**:
```python
"""Tests for calculator module."""
import pytest
from src.calculator import add, subtract, multiply, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
    assert add(100, -50) == 50

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
    assert divide(0, 5) == 0

def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(5, 0)
    with pytest.raises(ValueError):
        divide(0, 0)
```

**Test locally**:
```bash
pip install -r requirements.txt
pytest tests/ -v --cov=src
```

---

#### Step 4: Configure Codespaces (5 min)

**Create `.devcontainer/devcontainer.json`**:
```json
{
  "name": "Assignment Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "GitHub.copilot"
      ],
      "settings": {
        "python.testing.pytestEnabled": true,
        "python.testing.unittestEnabled": false,
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true
      }
    }
  },
  
  "postCreateCommand": "pip install -r requirements.txt",
  
  "forwardPorts": [],
  
  "remoteUser": "vscode"
}
```

**Test**: Create a Codespace from your repo to verify it works

---

#### Step 5: Set Up Autograding (10 min)

**Create `.github/workflows/classroom.yml`**:
```yaml
name: Autograding Tests

on:
  - push
  - workflow_dispatch

permissions:
  checks: write
  actions: read
  contents: read

jobs:
  run-autograding-tests:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        pytest tests/ -v --tb=short
    
    - name: Autograding Reporter
      uses: education/autograding-grading-reporter@v1
      if: always()
      with:
        runners: pytest
```

**Commit and push** to trigger first workflow run

---

#### Step 6: Write Student README (10 min)

**Update README.md** with:
```markdown
# Assignment [X]: [Name]

## Overview
[Brief description of what students will build]

## Learning Objectives
- [ ] [Objective 1]
- [ ] [Objective 2]
- [ ] [Objective 3]

## Getting Started

### Accept the Assignment
[GitHub Classroom link will go here]

### Open in Codespaces
1. Click "Code" → "Codespaces"
2. Click "Create codespace on main"
3. Wait 1-2 minutes for setup

### Run Tests
```bash
pytest tests/ -v
```

## Tasks
1. **Implement `add()` function** (10 points)
   - Should add two numbers
   - Test: `test_add` must pass

2. **Implement `subtract()` function** (10 points)
   - Should subtract b from a
   - Test: `test_subtract` must pass

3. **Implement `divide()` function** (30 points)
   - Should divide a by b
   - Must handle division by zero (raise ValueError)
   - Tests: `test_divide` and `test_divide_by_zero` must pass

## AI Usage Policy
✅ **Allowed**: Ask for explanations, syntax help, debugging assistance  
❌ **Not Allowed**: Copy entire solutions without understanding  
📝 **Required**: Include AI Assistance Declaration (see below)

## AI Assistance Declaration
Add this section to your submission:

### Tools Used
- [List AI tools you used]

### How AI Helped
1. **[Feature/Function]**
   - Prompt: "[What you asked]"
   - Used: [What you took]
   - Modified: [What you changed]
   - Learned: [What you understand now]

## Submission
1. Complete all functions
2. All tests must pass (green ✓ in Actions)
3. Add AI Assistance Declaration to README
4. Push to your repository
5. Submit repository URL to [LMS]

## Grading
- Functionality (50%): Tests pass
- Code Quality (20%): Readable, follows conventions
- AI Disclosure (20%): Complete and thoughtful
- Testing (10%): Coverage, edge cases

## Due Date
[Date and Time]

## Need Help?
- Office Hours: [Times]
- Discussion Forum: [Link]
- Email: [Instructor email]
```

---

#### Step 7: Create GitHub Classroom Assignment (5 min)

1. Go to [classroom.github.com](https://classroom.github.com)
2. Select your classroom (or create one)
3. Click "New Assignment"
4. **Title**: "Assignment [X]: [Name]"
5. **Deadline**: [Optional]
6. **Repository visibility**: Private recommended
7. **Template repository**: Select your template
8. **Enable Codespaces**: ✓ Check this
9. Configure autograding:
   - Test name: "Calculator Tests"
   - Setup: `pip install -r requirements.txt`
   - Run: `pytest tests/ -v`
   - Points: 100
10. Click "Create Assignment"
11. Copy invitation link
12. Add link to your template README

**Test the student experience**:
- Open invitation link in incognito window
- Accept assignment
- Open Codespace
- Implement one function
- Push and see Actions run

---

## ⚡ Option B: Add Automated Testing (30 min)

**For**: Existing assignments that lack automated testing

### Quick Win: GitHub Actions for Testing

**Step 1**: Add test file if missing (10 min)
**Step 2**: Create workflow file (5 min)
**Step 3**: Add badges to README (5 min)
**Step 4**: Test and iterate (10 min)

**See detailed steps in Session 2 materials**

---

## 📊 Option C: Create Comprehensive Rubric (30 min)

**For**: Assignments that need better assessment criteria

### Build Your Rubric

Use the [Contribution-Based Rubric Template](../rubrics/contribution-based.md) as a starting point.

**Customize for your assignment**:

1. **Adjust categories** (20 min):
   - Keep: Functionality, Code Quality, Documentation
   - Add: Domain-specific criteria
   - Modify: Point distribution
   - Include: AI disclosure (15-20%)

2. **Define levels** (5 min):
   - Exceptional (90-100%)
   - Proficient (80-89%)
   - Developing (70-79%)
   - Basic (60-69%)
   - Needs Work (<60%)

3. **Add examples** (5 min):
   - Show excellent work
   - Show common mistakes
   - Provide clear criteria

**Deliverable**: Rubric document added to assignment repo

---

## 🆕 Option D: Build From Scratch (60 min)

**For**: Faculty who want to create something entirely new

### Suggested Projects

**Beginner** (2-3 hours to complete):
- Command-line calculator
- To-do list manager
- Simple quiz app
- Text file parser

**Intermediate** (5-10 hours):
- REST API with database
- Web scraper with analysis
- Data visualization dashboard
- Simple game

**Advanced** (20+ hours):
- Full-stack web application
- Machine learning pipeline
- Mobile app
- Distributed system

### Build Process

Follow Option A steps but:
- Design your own requirements
- Create more complex starter code
- Write comprehensive tests
- Plan multi-week timeline
- Include agentic workflow elements

---

## ✅ Final Checklist

Before the session ends, ensure you have:

### Repository Setup
- [ ] Template repository created
- [ ] Marked as template (important!)
- [ ] All files committed and pushed
- [ ] .gitignore configured properly

### Student Experience
- [ ] Starter code is clear
- [ ] Tests are comprehensive
- [ ] README has all instructions
- [ ] AI policy is included
- [ ] Examples are helpful

### Automation
- [ ] Codespaces configuration works
- [ ] GitHub Actions runs successfully
- [ ] Autograding is configured
- [ ] Status badges added (optional)

### Classroom Integration
- [ ] Classroom assignment created
- [ ] Invitation link generated
- [ ] Link added to README
- [ ] Student roster prepared (optional)

### Assessment
- [ ] Rubric created or selected
- [ ] Point distribution clear
- [ ] AI disclosure criteria included
- [ ] Grading workflow defined

---

## 🎯 Deliverable

By the end of this session, you should have:

**1. Ready-to-Run Assignment** containing:
- ✅ Template repository with starter code
- ✅ Comprehensive test suite
- ✅ Codespaces configuration
- ✅ GitHub Actions autograding
- ✅ Clear student instructions
- ✅ AI usage policy

**2. Classroom Setup**:
- ✅ GitHub Classroom assignment created
- ✅ Invitation link ready to share
- ✅ Student roster imported (if applicable)

**3. Assessment Materials**:
- ✅ Grading rubric
- ✅ AI disclosure requirements
- ✅ Submission checklist

---

## 💡 Tips for Success

### During the Build Sprint

**Stay Focused**:
- Pick ONE option and finish it
- Don't try to be perfect
- Ship a working version
- You can iterate later

**Ask for Help**:
- Instructors circulating
- Pair with neighbor
- Check Slack/Discord
- Use AI tools!

**Test Everything**:
- Create a Codespace
- Run tests locally
- Accept your own assignment
- Student-test the experience

### After the Training

**Week 1**: Test with pilot group
- 2-3 volunteer students
- Collect feedback
- Fix issues
- Document learnings

**Week 2**: Roll out to full class
- Share invitation link
- Monitor initial usage
- Provide support
- Track metrics

**Week 3+**: Iterate and improve
- Adjust based on feedback
- Update documentation
- Refine rubrics
- Share with community

---

## 🆘 Troubleshooting Guide

### Common Issues

**Issue**: Codespace fails to start
- **Fix**: Check devcontainer.json syntax
- **Fix**: Verify image name is correct
- **Fix**: Try rebuilding container

**Issue**: Tests pass locally but fail in Actions
- **Fix**: Check for hardcoded paths
- **Fix**: Verify all dependencies in requirements file
- **Fix**: Check Python/Node version consistency

**Issue**: Students can't access assignment
- **Fix**: Check Classroom invitation link
- **Fix**: Verify GitHub accounts exist
- **Fix**: Ensure organization permissions correct

**Issue**: Autograding not awarding points
- **Fix**: Check GitHub Classroom autograding config
- **Fix**: Verify test names match
- **Fix**: Review Actions logs for errors

**Get Help**: Raise your hand or post in chat!

---

## 📚 Resources

### Templates
- [Assignment Template](../templates/assignment-template.md)
- [Agentic Workflow Storyboard](../templates/agentic-workflow-storyboard.md)
- [Contribution-Based Rubric](../rubrics/contribution-based.md)

### Documentation
- [GitHub Classroom Docs](https://docs.github.com/en/education/manage-coursework-with-github-classroom)
- [Codespaces Docs](https://docs.github.com/en/codespaces)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

### Examples
- [Autograding Examples](https://github.com/education/autograding-example-python)
- [Classroom Examples](https://github.com/education/classroom-examples)

---

## 🎓 Share Your Work

**At the end of the session** (5 minutes):

### Demo Gallery
- Pull up your assignment on screen
- Show 1-2 key features
- Share one challenge you overcame
- Get feedback from peers

### Upload to Community
- Add your assignment to faculty GitHub org
- Tag it: `assignment`, `[language]`, `[topic]`
- Others can learn from your work!

### Commit to Using It
- When will you deploy this?
- What support do you need?
- How will you iterate?

---

## ⏭️ Next: Closing Plenary

**Session 6: Faculty as Future-Makers** (4:30-5:00 PM)
- Reflect on the day
- Share commitments
- Join the community
- Get certificates

**What to Bring**:
- Your completed assignments
- Your experiences from today
- Your questions about implementation
- Your commitment to try AI-enhanced teaching

---

**Questions during build time?** Ask instructors, neighbors, or AI!

**Need inspiration?** Check examples in GitHub Classroom community.

**Stuck?** Pair program with someone nearby!

Let's build! 🚀
