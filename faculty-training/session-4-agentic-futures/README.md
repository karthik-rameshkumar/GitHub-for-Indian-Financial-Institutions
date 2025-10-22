# Session 4: Agentic Futures - Multi-Agent Patterns in Class

> **Time**: 2:00 PM – 3:15 PM (1 hour 15 minutes)  
> **Format**: Workshop + Design Sprint  
> **Goal**: Design a project using agentic workflow patterns

## 🎯 Learning Objectives

By the end of this session, you will:
- [ ] Understand what "agentic" means in practice
- [ ] Identify the key agent roles (planner, coder, tester, documenter, critic)
- [ ] Map a course project to an agentic workflow
- [ ] Determine which tasks are human-only vs. AI-assisted
- [ ] Create a project storyboard with checkpoints

## 📋 Session Overview

### Part 1: Understanding Agentic Systems (25 minutes)
- From assistive to agentic AI
- Multi-agent workflow patterns
- Live demos of agent systems
- GitHub Projects as agent orchestration

### Part 2: Designing Agentic Projects (30 minutes)
- Mapping projects to agent roles
- Identifying human decision points
- Creating workflow storyboards
- Assessment strategies

### Part 3: Hands-On Design Sprint (20 minutes)
- Choose a project from your course
- Create an agentic workflow storyboard
- Share and get feedback

## 🤖 What is Agentic AI?

### Evolution: Assistive → Agentic

#### Traditional Assistive AI
```
Human: "Write a function to sort numbers"
AI: [Generates code]
Human: "Now write tests for it"
AI: [Generates tests]
Human: "Now document it"
AI: [Generates docs]
```

**Characteristics**:
- Single-turn interactions
- Human drives every step
- No planning or reasoning
- Each prompt is independent

#### Agentic AI
```
Human: "Build a number sorting utility with tests and documentation"

Agent System:
1. PLANNER: "I need to: implement sort, write tests, create docs"
2. CODER: [Implements sorting function]
3. TESTER: [Generates and runs tests]
4. CRITIC: "Tests missing edge case for empty array"
5. CODER: [Fixes edge case]
6. DOCUMENTER: [Creates README with examples]
7. CRITIC: "All requirements met ✓"
```

**Characteristics**:
- Multi-step reasoning
- Plans and executes
- Self-corrects
- Uses tools and resources

### Why This Matters for Education

**Traditional Workflow Risk**:
Students copy-paste AI output → Don't understand → Don't learn

**Agentic Workflow Opportunity**:
Students orchestrate agents → Make decisions → Learn through coordination

**Key Insight**: 
> When students manage AI agents rather than just use AI tools, they develop higher-order skills: planning, evaluation, integration, and judgment.

---

## 🎭 The Five Agent Roles

### 1. Planner Agent 🗺️

**What It Does**:
- Breaks down requirements into tasks
- Suggests architectures and approaches
- Estimates complexity
- Proposes technology choices
- Creates project structure

**Example Prompts**:
```
"Given these requirements: [paste requirements], 
create a task breakdown with dependencies"

"Suggest 3 different architectural approaches for [problem]
with pros and cons of each"

"What would be a good project structure for [type of app]?"
```

**Human Responsibilities**:
- ✅ Define the problem (what, not how)
- ✅ Evaluate proposed approaches
- ✅ Make architectural decisions
- ✅ Prioritize features
- ✅ Set constraints (time, resources, scope)

**Student Learning**:
- System design thinking
- Trade-off analysis
- Requirement clarification
- Project decomposition

---

### 2. Coder Agent 💻

**What It Does**:
- Implements functions and classes
- Generates boilerplate code
- Suggests design patterns
- Refactors existing code
- Completes partial implementations

**Example Prompts**:
```
"Implement [function] that [does X] using [approach Y]"

"Refactor this code to use [design pattern]: [paste code]"

"Generate boilerplate for [framework] with [features]"
```

**Human Responsibilities**:
- ✅ Review all generated code
- ✅ Verify correctness
- ✅ Handle edge cases
- ✅ Ensure integration
- ✅ Maintain code quality
- ✅ Apply domain knowledge

**Student Learning**:
- Code reading and review
- Integration skills
- Edge case thinking
- Quality standards

---

### 3. Tester Agent 🧪

**What It Does**:
- Generates test cases
- Suggests edge cases
- Creates test data/fixtures
- Proposes test strategies
- Identifies coverage gaps

**Example Prompts**:
```
"Generate comprehensive test cases for: [function]"

"What edge cases should I test for [feature]?"

"Create test fixtures for [data model]"

"Suggest integration tests for [component interaction]"
```

**Human Responsibilities**:
- ✅ Determine what needs testing
- ✅ Evaluate test quality
- ✅ Add domain-specific tests
- ✅ Interpret test results
- ✅ Debug failures
- ✅ Decide on acceptance criteria

**Student Learning**:
- Test strategy design
- Quality assurance thinking
- Debugging skills
- Verification techniques

---

### 4. Documenter Agent 📝

**What It Does**:
- Generates README templates
- Creates docstrings/comments
- Drafts user guides
- Produces API documentation
- Suggests examples

**Example Prompts**:
```
"Generate a README for [project] including [sections]"

"Write docstrings for these functions: [paste code]"

"Create usage examples for [feature] showing [scenarios]"

"Draft API documentation for [endpoints]"
```

**Human Responsibilities**:
- ✅ Explain the "why" behind decisions
- ✅ Provide context AI doesn't have
- ✅ Ensure accuracy
- ✅ Add troubleshooting guides
- ✅ Make it user-focused
- ✅ Document limitations

**Student Learning**:
- Technical writing
- User empathy
- Communication skills
- Knowledge synthesis

---

### 5. Critic Agent 🔍

**What It Does**:
- Reviews code quality
- Identifies potential bugs
- Suggests improvements
- Checks best practices
- Points out security issues

**Example Prompts**:
```
"Review this code and suggest improvements: [paste code]"

"What potential issues do you see in [implementation]?"

"Check this code for security vulnerabilities: [paste code]"

"How can I make this more [efficient/readable/maintainable]?"
```

**Human Responsibilities**:
- ✅ Evaluate critique validity
- ✅ Prioritize improvements
- ✅ Make judgment calls
- ✅ Balance trade-offs
- ✅ Decide what to change vs. keep
- ✅ Apply experience and taste

**Student Learning**:
- Critical evaluation
- Quality judgment
- Trade-off analysis
- Decision-making

---

## 🗺️ Live Demos

### Demo 1: Hugging Face Agent Spaces

**Visit**: [huggingface.co/spaces](https://huggingface.co/spaces)

**Search for**: "agent" or "multi-agent" or "autonomous"

**What to Observe**:
- How agent plans before acting
- How it uses tools
- How it reflects on results
- How it recovers from errors

**Discussion**:
- What makes this "agentic" vs. just "AI"?
- What skills would students need to work with agents?
- What could go wrong?

---

### Demo 2: GitHub Projects as Agent Orchestration

**Scenario**: Modeling a term project as agent workflow

**Setup a GitHub Project Board**:

**Columns (Workflow Stages)**:
1. 📋 Backlog (All tasks)
2. 🗺️ Planning (What Planner Agent handles)
3. 💻 Implementation (What Coder Agent handles)
4. 🧪 Testing (What Tester Agent handles)
5. 📝 Documentation (What Documenter Agent handles)
6. 🔍 Review (What Critic Agent handles)
7. ✅ Done

**Sample Issues (Agent Tasks)**:

```markdown
Issue #1: [PLANNER] Design System Architecture
- Analyze requirements
- Propose 3 approaches
- Create component diagram
- Estimate complexity
**Human Decision**: Choose approach and justify

Issue #2: [CODER] Implement User Authentication
- Create login endpoint
- Hash passwords
- Generate JWT tokens
- Handle errors
**Human Decision**: Review security, test edge cases

Issue #3: [TESTER] Create Test Suite for Auth
- Unit tests for password hashing
- Integration tests for login flow
- Edge cases (invalid credentials, missing fields)
**Human Decision**: Are these tests sufficient? Add more?

Issue #4: [DOCUMENTER] Write API Documentation
- Document auth endpoints
- Provide usage examples
- Explain error responses
**Human Decision**: Is this clear for users? Add troubleshooting?

Issue #5: [CRITIC] Security Review of Auth System
- Check for SQL injection
- Verify password strength requirements
- Review token expiration
**Human Decision**: Which issues to fix now vs. later?
```

**Student Workflow**:
1. Move tasks through columns
2. At each stage, use appropriate agent
3. Document agent interactions
4. Make human decisions at checkpoints
5. Move to next stage

**Benefits**:
- Visualizes workflow
- Clarifies agent vs. human work
- Tracks progress
- Natural assessment points

---

## 🎨 Designing Agentic Projects

### Step 1: Choose Appropriate Projects

**Good Candidates for Agentic Workflow**:
- ✅ Multi-week projects (3-8 weeks)
- ✅ Multiple distinct phases
- ✅ Requires integration of components
- ✅ Benefits from iteration
- ✅ Has clear quality criteria

**Examples**:
- Web application (frontend + backend + database)
- Data pipeline (collection + processing + analysis + visualization)
- Mobile app (UI + logic + API integration + testing)
- Game development (engine + gameplay + assets + testing)

**Not Ideal**:
- ❌ Single-function exercises
- ❌ Purely conceptual projects
- ❌ Projects without code (e.g., only research papers)
- ❌ Too simple (< 1 week)

---

### Step 2: Map Project to Agent Roles

**Exercise**: Take a project and fill out this template

```markdown
## Project: [Name]

### Phase 1: Planning (Week 1)
**Planner Agent Tasks**:
- [ ] Analyze requirements
- [ ] Propose architecture
- [ ] Break down into features
- [ ] Suggest tech stack

**Human Decisions**:
- [ ] Finalize architecture (with justification)
- [ ] Prioritize features
- [ ] Set milestones

**Checkpoint**: Architecture document + decision rationale

---

### Phase 2: Implementation (Weeks 2-4)
**Coder Agent Tasks**:
- [ ] Generate project structure
- [ ] Implement feature X
- [ ] Implement feature Y
- [ ] Refactor for clarity

**Human Decisions**:
- [ ] Review all generated code
- [ ] Add domain-specific logic
- [ ] Handle integration
- [ ] Ensure consistency

**Checkpoint**: Working implementation + code review notes

---

### Phase 3: Testing (Week 4-5)
**Tester Agent Tasks**:
- [ ] Generate unit tests
- [ ] Suggest integration tests
- [ ] Propose edge cases
- [ ] Create test data

**Human Decisions**:
- [ ] Evaluate test quality
- [ ] Add domain-specific tests
- [ ] Debug failures
- [ ] Determine acceptable coverage

**Checkpoint**: Test suite + coverage report + test strategy doc

---

### Phase 4: Documentation (Week 5-6)
**Documenter Agent Tasks**:
- [ ] Generate README
- [ ] Create API docs
- [ ] Write usage examples
- [ ] Draft user guide

**Human Decisions**:
- [ ] Add context and rationale
- [ ] Ensure accuracy
- [ ] Make user-friendly
- [ ] Add troubleshooting

**Checkpoint**: Complete documentation + peer review

---

### Phase 5: Review & Polish (Week 6-7)
**Critic Agent Tasks**:
- [ ] Code quality review
- [ ] Security check
- [ ] Performance analysis
- [ ] Improvement suggestions

**Human Decisions**:
- [ ] Prioritize improvements
- [ ] Balance trade-offs
- [ ] Implement high-priority fixes
- [ ] Document known limitations

**Checkpoint**: Polished project + improvement log

---

### Phase 6: Reflection (Week 7)
**100% Human**:
- [ ] What did I learn?
- [ ] How did agents help/hinder?
- [ ] What would I do differently?
- [ ] What was hardest/easiest?

**Checkpoint**: Reflection essay + presentation
```

---

### Step 3: Define Human-Only Zones

**Critical: Some things MUST remain human**

#### 🎨 Creative Vision
- What should this project do?
- Who is it for?
- What's the user experience?
- What makes it unique?

#### ⚖️ Ethical Decisions
- Is this ethical to build?
- Who might be harmed?
- What biases exist?
- What's the environmental impact?

#### 🎓 Learning & Reflection
- What did I learn?
- How did I grow?
- What was challenging?
- What would I do differently?

#### 🔍 Evaluation & Assessment
- Is this good work?
- Does it meet requirements?
- What's the grade?
- What feedback is helpful?

**Add these to your project template!**

---

## 💻 Hands-On Design Sprint (20 minutes)

### Your Turn: Create an Agentic Project Storyboard

**Goal**: Design one project from your course using agentic workflow

**Use the template**: [`../templates/agentic-workflow-storyboard.md`](../templates/agentic-workflow-storyboard.md)

### Sprint Steps

#### 1. Choose Your Project (3 min)
- Pick a multi-week project from your course
- One that has multiple phases
- One where AI assistance makes sense

#### 2. Map to Phases (5 min)
For each phase:
- What agent role is primary?
- What can the agent do?
- What must the human do?
- What's the checkpoint/deliverable?

Use this quick template:
```
Phase: [Name]
Agent: [Planner/Coder/Tester/Documenter/Critic]
AI Can: [bullet list]
Human Must: [bullet list]
Checkpoint: [what to assess]
```

#### 3. Identify Human-Only Zones (3 min)
What decisions or work cannot be delegated to agents?
- Creative vision?
- Ethical considerations?
- Evaluation?
- Reflection?

#### 4. Create Checkpoint Strategy (4 min)
When will you assess:
- Agent use appropriateness?
- Code quality?
- Understanding?
- Learning progress?

How will you grade:
- Process vs. output?
- Agent transparency?
- Human decisions quality?

#### 5. Quick Sketch (5 min)
Draw a simple workflow diagram:
```
[Planning] → [Implementation] → [Testing] → [Documentation] → [Review]
    🤖+👤         🤖+👤            🤖+👤         🤖+👤          🤖+👤
     ↓              ↓                ↓             ↓            ↓
  [Checkpoint]  [Checkpoint]    [Checkpoint]  [Checkpoint] [Checkpoint]
```

### Share Out (If Time)
- Pair up with a neighbor
- Share your storyboard
- Get feedback
- Refine

---

## 🎯 Deliverable

**Agentic Workflow Storyboard for One Project**

**Required Elements**:
- [ ] Project name and overview
- [ ] 5 phases mapped to agent roles
- [ ] For each phase:
  - [ ] What agents can do
  - [ ] What humans must do
  - [ ] Checkpoint deliverable
- [ ] Human-only zones identified
- [ ] Assessment strategy outlined
- [ ] Simple workflow diagram

**Format**: Use the provided template or your own format

**Submission**: 
- Save to your faculty training folder
- Share in GitHub Discussions
- Bring to Session 5 to implement

---

## 💡 Key Takeaways

### About Agentic Systems
1. **Not just chat** - multi-step reasoning and planning
2. **Orchestration** - multiple specialized agents working together
3. **Tool use** - agents can execute actions, not just generate text
4. **Iteration** - agents can reflect and improve

### About Teaching with Agents
1. **Higher-order skills** - students learn planning and coordination
2. **Transparency** - track agent use through issues/PRs
3. **Checkpoints** - assess at each phase, not just final product
4. **Human decisions** - explicitly require human judgment

### About Project Design
1. **Map to roles** - break project into agent-appropriate phases
2. **Define boundaries** - be clear about what's human-only
3. **Build in reflection** - students document their orchestration
4. **Assess process** - grade decision-making, not just output

---

## 📚 Resources

### Understanding Agentic AI
- [What are AI Agents?](https://www.anthropic.com/index/what-are-ai-agents)
- [Multi-Agent Systems](https://www.microsoft.com/en-us/research/project/multi-agent-systems/)
- [Agent Design Patterns](https://www.microsoft.com/en-us/research/blog/autogen-enabling-next-generation-large-language-model-applications/)

### GitHub for Project Management
- [GitHub Projects Guide](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Issues and Pull Requests](https://docs.github.com/en/issues)
- [Using Projects for Course Management](https://docs.github.com/en/education)

### Example Agentic Projects
- [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT)
- [AgentGPT](https://github.com/reworkd/AgentGPT)
- [Agent Examples on Hugging Face](https://huggingface.co/spaces?search=agent)

---

## ⏭️ Next Session (After Break)

**Session 5: Build the AI-Powered Classroom**
- Implement your designs hands-on
- Create ready-to-run assignments
- Build GitHub Classroom + Codespaces + Actions
- Create rubrics and assessment tools

**What to Bring**:
- Your agentic workflow storyboard
- Your Copilot-aware assignment draft
- Ideas for what to build in Session 5

---

**Tea Break**: 3:15 - 3:30 PM ☕

See you back at 3:30 for the final hands-on build session!
