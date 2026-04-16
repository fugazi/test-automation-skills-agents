# Test Design Techniques (ISTQB Foundation Level)

Test design techniques transform the test basis into test conditions and test cases. Choose techniques based on the type of testing and risk level.

## Technique Categories

| Category             | Focus                              | Techniques                                             |
| -------------------- | ---------------------------------- | ------------------------------------------------------ |
| **Black-box**        | External behavior (inputs/outputs) | EP, BVA, Decision tables, State transitions, Use cases |
| **White-box**        | Internal structure (code)          | Statement, Branch, Condition coverage                  |
| **Experience-based** | Tester knowledge                   | Error guessing, Exploratory, Checklist-based           |

---

## Black-Box Techniques

### 1. Equivalence Partitioning (EP)

**Use when:** Inputs can be grouped into classes that should behave the same way.

**How it works:**

1. Identify input parameters and their valid/invalid ranges
2. Divide each into partitions (groups of equivalent values)
3. Select one representative value per partition
4. Each partition needs at least one test case

**Example: Age field (valid range: 18-65)**

| Partition | Values | Type    | Representative |
| --------- | ------ | ------- | -------------: |
| P1        | < 18   | Invalid |             15 |
| P2        | 18-65  | Valid   |             30 |
| P3        | > 65   | Invalid |             70 |

**Test cases:** 3 tests (one per partition)

---

### 2. Boundary Value Analysis (BVA)

**Use when:** Defects often occur at boundaries of ranges/limits.

**How it works:**

1. Identify boundaries from equivalence partitions
2. Test values at, just below, and just above each boundary
3. Two-value BVA: boundary and one neighbor
4. Three-value BVA: boundary and both neighbors

**Example: Age field (valid range: 18-65)**

| Boundary | Below |  At | Above |
| -------- | ----: | --: | ----: |
| Min (18) |    17 |  18 |    19 |
| Max (65) |    64 |  65 |    66 |

**Test values (three-value):** 17, 18, 19, 64, 65, 66 (6 tests)

**Combining EP + BVA:**

- EP confirms partitions work
- BVA tests transitions between partitions

---

### 3. Decision Table Testing

**Use when:** Business rules combine multiple conditions to determine actions.

**How it works:**

1. List all conditions (inputs)
2. List all actions (outputs)
3. Create columns for all condition combinations
4. Mark which actions apply for each combination
5. Eliminate impossible or redundant combinations
6. One test per rule (column)

**Example: Discount rules**

| Conditions    | R1  | R2  | R3  | R4  |
| ------------- | :-: | :-: | :-: | :-: |
| Member?       |  Y  |  Y  |  N  |  N  |
| Order > $100? |  Y  |  N  |  Y  |  N  |
| **Actions**   |     |     |     |     |
| 20% discount  |  X  |     |     |     |
| 10% discount  |     |  X  |  X  |     |
| No discount   |     |     |     |  X  |

**Test cases:** 4 tests (one per rule)

**Simplified decision tables:** Collapse rows when a condition doesn't affect the action.

---

### 4. State Transition Testing

**Use when:** System behavior depends on state/history (orders, sessions, workflows).

**How it works:**

1. Identify all states
2. Identify all transitions (events that cause state changes)
3. Draw state diagram
4. Test valid transitions (happy paths)
5. Test invalid transitions (should be rejected)
6. Test transition sequences (0-switch, 1-switch, etc.)

**Example: Order status**

```
[New] --confirm--> [Confirmed] --ship--> [Shipped] --deliver--> [Delivered]
                        |                     |
                        +--cancel--> [Cancelled] <--cancel--+
```

**State transition table:**

| Current State | Event   | Next State | Action            |
| ------------- | ------- | ---------- | ----------------- |
| New           | confirm | Confirmed  | Send confirmation |
| New           | cancel  | Cancelled  | Refund            |
| Confirmed     | ship    | Shipped    | Send tracking     |
| Confirmed     | cancel  | Cancelled  | Refund            |
| Shipped       | deliver | Delivered  | Complete order    |
| Shipped       | cancel  | Cancelled  | Refund + return   |

**Coverage levels:**

- **All states:** Each state visited at least once
- **All transitions (0-switch):** Each transition exercised
- **1-switch:** Every pair of adjacent transitions

---

### 5. Use Case / Scenario Testing

**Use when:** Testing end-to-end user journeys and workflows.

**How it works:**

1. Identify use cases from requirements
2. Define main success scenario (happy path)
3. Define alternate flows (variations)
4. Define exception flows (error handling)
5. Create tests for each flow

**Example: Online purchase**

| Flow Type | Scenario            | Steps                                                                 |
| --------- | ------------------- | --------------------------------------------------------------------- |
| Main      | Successful purchase | Login → Search → Add to cart → Checkout → Pay → Confirm               |
| Alternate | Guest checkout      | Skip login → Search → Add to cart → Checkout as guest → Pay → Confirm |
| Alternate | Apply coupon        | ... → Add to cart → Apply coupon → Checkout → ...                     |
| Exception | Payment declined    | ... → Pay (declined) → Show error → Retry                             |
| Exception | Out of stock        | ... → Add to cart (out of stock) → Show message                       |

---

## Coverage Criteria Summary

| Technique        | Coverage Goal           | Minimum Tests                  |
| ---------------- | ----------------------- | ------------------------------ |
| EP               | One value per partition | Number of partitions           |
| BVA              | Boundary values tested  | 2-3 per boundary               |
| Decision Table   | One test per rule       | Number of rules/columns        |
| State Transition | All transitions covered | Number of transitions          |
| Use Case         | All flows covered       | Main + alternates + exceptions |

---

## Selecting Techniques

| Situation                     | Recommended Technique        |
| ----------------------------- | ---------------------------- |
| Input validation, form fields | EP + BVA                     |
| Complex business rules        | Decision tables              |
| Workflows, lifecycles         | State transitions            |
| User journeys                 | Use case testing             |
| API testing                   | EP + BVA + Decision tables   |
| UI forms                      | EP + BVA                     |
| High-risk/unknown area        | Exploratory + Error guessing |

## Combining Techniques

For thorough coverage, combine techniques:

1. **EP + BVA** for input fields (partitions + boundaries)
2. **Decision tables** for rule combinations
3. **State transitions** for status/workflow
4. **Use cases** for end-to-end validation
5. **Exploratory** for edge cases and discovery

**Example: Testing a login form**

| Technique        | Test Focus                                      |
| ---------------- | ----------------------------------------------- |
| EP               | Valid/invalid usernames, passwords              |
| BVA              | Min/max lengths for username/password           |
| Decision table   | Password rules (length + special char + number) |
| State transition | Account states (active, locked, expired)        |
| Use case         | Login → session → logout flow                   |
| Error guessing   | SQL injection, XSS in inputs                    |
