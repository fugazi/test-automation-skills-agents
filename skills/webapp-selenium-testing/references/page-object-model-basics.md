# Page Object Model Basics

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

Comprehensive guide for implementing the Page Object Model pattern in Selenium tests with Java.

## What is Page Object Model?

Page Object Model (POM) is a design pattern that creates an abstraction layer between test code and page implementation. Each page (or component) in your application gets its own class that encapsulates:

- **Locators** for elements on the page
- **Methods** for interactions and actions
- **Fluent interface** for method chaining

### Benefits

| Benefit         | Description                             |
| --------------- | --------------------------------------- |
| Maintainability | Change locator once, not in every test  |
| Readability     | Tests read like user stories            |
| Reusability     | Share page logic across tests           |
| Separation      | Test logic separate from implementation |
| Scalability     | Easy to add new pages/components        |

---

## Directory Structure (Maven)

```
src/
├── main/java/com/project/
│   ├── base/
│   │   ├── BasePage.java           # Common page functionality
│   │   └── BaseComponent.java      # Reusable UI components
│   ├── pages/
│   │   ├── LoginPage.java
│   │   ├── DashboardPage.java
│   │   └── ProductPage.java
│   ├── components/
│   │   ├── HeaderComponent.java
│   │   ├── FooterComponent.java
│   │   └── ModalComponent.java
│   ├── factories/
│   │   └── WebDriverFactory.java
│   ├── models/
│   │   └── User.java               # Data models with Lombok
│   └── utils/
│       ├── ConfigReader.java
│       └── WaitUtils.java
├── main/resources/
│   └── config.properties
└── test/java/com/project/
    ├── base/
    │   └── BaseTest.java           # Test setup/teardown
    └── tests/
        ├── LoginTest.java
        └── DashboardTest.java
```

---
