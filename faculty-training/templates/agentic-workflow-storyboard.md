# Agentic Workflow Storyboard Template

> **Purpose**: Design a project that blends human creativity with AI agent capabilities  
> **Use Case**: Map course projects to multi-agent workflows with clear human decision points

## 📋 Project Overview

### Project Name
[Name of the project]

### Course Context
**Course**: [Course name]  
**Level**: [Freshman/Sophomore/Junior/Senior/Graduate]  
**Duration**: [Timeline - e.g., 4 weeks, 1 semester]  
**Team Size**: [Individual / Pairs / Teams of X]

### Learning Objectives
What should students learn from this project?
1. [Learning objective 1]
2. [Learning objective 2]
3. [Learning objective 3]

### Project Description
[2-3 sentence overview of what students will build]

---

## 🤖 Agent Roles & Human Responsibilities

### The Agentic Pipeline

Map your project phases to agent roles. For each role, identify:
- What an AI agent could do
- What humans must decide/evaluate
- Where handoffs occur

---

### Phase 1: Planning & Requirements

#### 🤖 Planner Agent Role
**What AI Can Do**:
- Generate initial project structure
- Suggest implementation approaches
- Break down tasks into subtasks
- Estimate complexity
- Propose technology choices

**Example AI Prompts for Students**:
```
"Given these requirements: [paste requirements], 
suggest a project structure and task breakdown"

"What are 3 different approaches to implement [feature]? 
Compare their pros and cons"
```

#### 👤 Human Responsibilities (Students)
**What Humans Must Do**:
- [ ] Define the problem statement
- [ ] Clarify ambiguous requirements
- [ ] Make architectural decisions
- [ ] Evaluate trade-offs between AI suggestions
- [ ] Justify technology choices

**Critical Thinking Required**:
- Why did you choose approach A over approach B?
- What assumptions are you making?
- What are the risks and how will you mitigate them?

**Deliverable**: Requirements document + Architecture decision record (ADR)

**Assessment Checkpoint**: ✅ Students submit their plan with AI prompt history and justifications

---

### Phase 2: Implementation & Coding

#### 🤖 Coder Agent Role
**What AI Can Do**:
- Generate boilerplate code
- Suggest implementation patterns
- Complete code based on context
- Refactor existing code
- Generate utility functions

**Example AI Prompts for Students**:
```
"Generate a [class/function] that [does X] with [these parameters]"

"Refactor this code to improve [readability/performance]: [paste code]"

"What's the idiomatic way to [do X] in [language/framework]?"
```

#### 👤 Human Responsibilities (Students)
**What Humans Must Do**:
- [ ] Review all AI-generated code
- [ ] Test AI suggestions thoroughly
- [ ] Handle edge cases AI might miss
- [ ] Ensure code meets requirements
- [ ] Maintain code quality standards
- [ ] Integrate components meaningfully

**Critical Thinking Required**:
- Does this AI-generated code actually solve the problem?
- What edge cases am I not seeing?
- Is this code maintainable and readable?
- How does this fit into the larger system?

**Deliverable**: Working code with clear commit history showing human decisions

**Assessment Checkpoint**: ✅ Code review with instructor focusing on modifications to AI suggestions

---

### Phase 3: Testing & Validation

#### 🤖 Tester Agent Role
**What AI Can Do**:
- Generate test cases
- Suggest edge cases to test
- Create test data/fixtures
- Write test descriptions
- Suggest coverage improvements

**Example AI Prompts for Students**:
```
"Generate comprehensive test cases for this function: [paste function]"

"What edge cases should I test for [feature description]?"

"Help me write a test that verifies [specific behavior]"
```

#### 👤 Human Responsibilities (Students)
**What Humans Must Do**:
- [ ] Determine what needs testing
- [ ] Evaluate quality of test cases
- [ ] Add domain-specific test scenarios
- [ ] Interpret test results
- [ ] Debug failing tests
- [ ] Ensure meaningful coverage

**Critical Thinking Required**:
- Are these tests actually validating the right behavior?
- What would a user do that might break this?
- Am I testing implementation or behavior?
- What's my confidence level in this code?

**Deliverable**: Comprehensive test suite with ≥80% coverage

**Assessment Checkpoint**: ✅ Test report + reflection on test strategy

---

### Phase 4: Documentation & Communication

#### 🤖 Documenter Agent Role
**What AI Can Do**:
- Generate README templates
- Create docstrings/comments
- Draft user guides
- Suggest examples and tutorials
- Create API documentation

**Example AI Prompts for Students**:
```
"Generate a README for this project that includes [sections]"

"Write docstrings for this function: [paste function]"

"Create usage examples for [feature]"
```

#### 👤 Human Responsibilities (Students)
**What Humans Must Do**:
- [ ] Explain the "why" behind decisions
- [ ] Provide context AI doesn't have
- [ ] Create meaningful examples
- [ ] Ensure documentation accuracy
- [ ] Add troubleshooting guides
- [ ] Document limitations

**Critical Thinking Required**:
- Who is the audience for this documentation?
- What would confuse a new user?
- What problems might they encounter?
- What's the most important thing to explain?

**Deliverable**: Complete documentation (README, comments, user guide)

**Assessment Checkpoint**: ✅ Documentation review by peer student (can they understand and use the project?)

---

### Phase 5: Review & Critique

#### 🤖 Critic Agent Role
**What AI Can Do**:
- Identify potential bugs
- Suggest improvements
- Point out code smells
- Check against best practices
- Recommend refactoring

**Example AI Prompts for Students**:
```
"Review this code and suggest improvements: [paste code]"

"What potential issues do you see in this implementation?"

"How could I make this code more [efficient/readable/maintainable]?"
```

#### 👤 Human Responsibilities (Students)
**What Humans Must Do**:
- [ ] Evaluate AI critique validity
- [ ] Prioritize improvements
- [ ] Make judgment calls on trade-offs
- [ ] Decide what to change vs. keep
- [ ] Explain decisions to reject suggestions

**Critical Thinking Required**:
- Is this suggestion actually an improvement?
- What are the costs/benefits of this change?
- Does this align with project goals?
- What would the impact be on users?

**Deliverable**: Refactored code + changelog explaining improvements

**Assessment Checkpoint**: ✅ Final code review with rationale for accepting/rejecting AI suggestions

---

## 🎯 Human-Only Zones

Some aspects of this project **MUST** remain entirely human-driven:

### 1. Ethics & Impact Assessment
**Why Human-Only**: Requires societal context, values, and long-term thinking

**Questions Students Must Answer**:
- Who might be affected by this project?
- What are potential misuses?
- What biases might exist in the data/implementation?
- What's the environmental impact?

**Deliverable**: Ethics statement (1-2 pages)

---

### 2. Evaluation & Grading
**Why Human-Only**: Requires holistic judgment, learning assessment, and fairness

**What Instructor Evaluates**:
- Learning growth (not just output quality)
- Process (not just final product)
- Collaboration and communication
- Critical thinking and reflection

**Assessment Method**: [Your grading approach]

---

### 3. Creative Vision & Direction
**Why Human-Only**: Requires taste, intuition, and artistic judgment

**Student Decisions**:
- Overall project vision and goals
- User experience priorities
- Design philosophy
- Feature priorities

**Deliverable**: Vision statement + design mockups/wireframes

---

### 4. Narrative & Storytelling
**Why Human-Only**: Requires authenticity, voice, and emotional intelligence

**Required Elements**:
- Project origin story
- Development journey blog
- Demo presentation
- Reflection essay

**Deliverable**: Project narrative (blog post or presentation)

---

## 📊 Assessment & Checkpoints

### Checkpoint Schedule

| Week | Phase | Checkpoint | Deliverable |
|------|-------|------------|-------------|
| 1 | Planning | Requirements review | Plan + ADR |
| 2-3 | Implementation | Code review | Working code |
| 4 | Testing | Test report | Test suite |
| 5 | Documentation | Docs review | Complete docs |
| 6 | Review | Final review | Polished project |
| 7 | Presentation | Demo | Presentation + essay |

### Grading Distribution

| Component | Points | Human vs. AI Work |
|-----------|--------|-------------------|
| Requirements & Planning | 15% | 70% human, 30% AI-assisted |
| Implementation | 25% | 50% human, 50% AI-assisted |
| Testing | 20% | 60% human, 40% AI-assisted |
| Documentation | 15% | 40% human, 60% AI-assisted |
| Code Review & Refinement | 10% | 80% human, 20% AI-assisted |
| Ethics & Reflection | 10% | 100% human |
| Presentation | 5% | 100% human |

**Total**: 100%

---

## 🔄 Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: PLANNING                                          │
│  🤖 AI: Suggest structure, breakdown tasks                  │
│  👤 Human: Decide architecture, justify choices             │
│  ✅ Checkpoint: Plan + AI prompts + justifications          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: IMPLEMENTATION                                    │
│  🤖 AI: Generate code, suggest patterns                     │
│  👤 Human: Review, test, integrate, handle edge cases       │
│  ✅ Checkpoint: Code + commit history                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 3: TESTING                                           │
│  🤖 AI: Generate tests, suggest edge cases                  │
│  👤 Human: Evaluate test quality, add domain tests          │
│  ✅ Checkpoint: Test suite + reflection                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 4: DOCUMENTATION                                     │
│  🤖 AI: Generate docs, create examples                      │
│  👤 Human: Add context, ensure accuracy, user focus         │
│  ✅ Checkpoint: Complete docs + peer review                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 5: REVIEW                                            │
│  🤖 AI: Suggest improvements, identify issues               │
│  👤 Human: Prioritize, decide on changes, explain decisions │
│  ✅ Checkpoint: Refactored code + changelog                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  HUMAN-ONLY ZONES (Throughout)                             │
│  • Ethics & Impact Assessment                               │
│  • Creative Vision & Direction                              │
│  • Narrative & Storytelling                                 │
│  • Critical Evaluation of AI Suggestions                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 Student Reflection Questions

At each checkpoint, students should answer:

### Process Reflection
1. How did you use AI in this phase?
2. What prompts were most/least effective?
3. What did AI suggest that you rejected? Why?
4. What did you have to do entirely yourself?

### Learning Reflection
1. What did you learn from AI interactions?
2. What confused you that AI couldn't help with?
3. How did you verify AI suggestions?
4. What would you do differently next time?

### Critical Thinking
1. What assumptions did AI make?
2. What did AI miss or get wrong?
3. How did you ensure correctness?
4. What required human judgment?

---

## 💡 Tips for Faculty

### Setting Up This Workflow

1. **Start with Clear Boundaries**
   - Define what AI can/can't do for each phase
   - Be explicit about human-only requirements
   - Provide example prompts

2. **Build in Checkpoints**
   - Frequent, small checkpoints work better
   - Focus on process, not just output
   - Require justification of AI use

3. **Emphasize Learning**
   - Grade the journey, not just destination
   - Reward good questions to AI
   - Value thoughtful critique of AI suggestions

4. **Create Rubrics**
   - Separate rubrics for human vs. AI-assisted work
   - Reward transparency and reflection
   - Penalize blind acceptance of AI output

### Common Pitfalls to Avoid

❌ **Too Much AI Freedom**: Students copy-paste without understanding  
✅ **Solution**: Require explanation of all AI-generated code

❌ **No AI Guidance**: Students don't know how to use tools effectively  
✅ **Solution**: Provide example prompts and demos

❌ **Binary Assessment**: Either perfect or failing  
✅ **Solution**: Use checkpoint-based grading with feedback loops

❌ **Ignoring Process**: Only grading final output  
✅ **Solution**: Require git history, AI prompt logs, and reflections

---

## 🎓 Example Projects

### Example 1: Web Application (6 weeks)
- **Planner**: System design, tech stack choice
- **Coder**: Frontend/backend implementation
- **Tester**: E2E and unit tests
- **Documenter**: API docs, user guide
- **Critic**: Performance, security review
- **Human-Only**: UX design, accessibility, ethics

### Example 2: Data Analysis Pipeline (4 weeks)
- **Planner**: Pipeline architecture
- **Coder**: Data processing scripts
- **Tester**: Data validation, edge cases
- **Documenter**: Analysis report, visualizations
- **Critic**: Statistical validity review
- **Human-Only**: Interpretation, bias analysis

### Example 3: Mobile App (8 weeks)
- **Planner**: Feature roadmap, architecture
- **Coder**: UI implementation, business logic
- **Tester**: UI testing, user scenarios
- **Documenter**: User manual, in-app help
- **Critic**: Usability review
- **Human-Only**: User research, design system

---

## 📚 Resources

### For Students
- [Effective Prompting Guide](../docs/prompting-guide.md)
- [AI Assistance Declaration Template](../policies/ai-use-disclosure.md)
- [Critical Evaluation Checklist](../docs/evaluation-checklist.md)

### For Faculty
- [Agentic Workflow in Education - Paper](link)
- [Assessment Rubrics](../rubrics/)
- [Example Projects](../examples/)

---

## ✅ Faculty Checklist

Before using this storyboard with students:

- [ ] Customize phases for your project
- [ ] Define clear AI boundaries
- [ ] Create example prompts
- [ ] Set up checkpoints and deadlines
- [ ] Prepare assessment rubrics
- [ ] Test AI tools yourself
- [ ] Brief students on expectations
- [ ] Prepare for office hours questions

---

**Version**: 1.0  
**Last Updated**: [Date]  
**License**: MIT - Free to adapt for educational use

---

*Part of the LeSuccess Faculty Training curriculum. Learn more at [../README.md](../README.md)*
