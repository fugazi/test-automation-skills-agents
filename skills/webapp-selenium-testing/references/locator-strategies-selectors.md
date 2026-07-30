# Locator Strategies Selectors

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original locator-strategies.md. See the other related files in this folder.

## CSS Selectors (Flexible)

Use semantic CSS selectors when IDs aren't available:

```java
// [ok] GOOD: Semantic CSS selectors
By.cssSelector("form#login input[type='email']")
By.cssSelector("button[aria-label='Close dialog']")
By.cssSelector("input[placeholder='Search...']")
By.cssSelector("table#users tbody tr")

// Attribute-based
By.cssSelector("[name='email']")
By.cssSelector("[type='submit']")
By.cssSelector("[role='button']")
By.cssSelector("[aria-expanded='true']")

// Combinators
By.cssSelector("div.container > form")          // Direct child
By.cssSelector("nav a")                          // Descendant
By.cssSelector("input + button")                 // Adjacent sibling
By.cssSelector("h1 ~ p")                         // General sibling

// Pseudo-selectors
By.cssSelector("li:first-child")
By.cssSelector("tr:nth-child(2)")
By.cssSelector("button:not([disabled])")
```

---

## Name and Class Locators

```java
// Name attribute (good for form fields)
By.name("username")
By.name("password")
By.name("remember-me")

// Class name (single class only)
By.className("btn-primary")
By.className("error-message")

// Multiple classes with CSS
By.cssSelector(".btn.btn-primary.large")
```

---

## Link Text Locators

For anchor (`<a>`) elements:

```java
// Exact text match
By.linkText("Sign up")
By.linkText("Forgot password?")

// Partial text match
By.partialLinkText("Sign")
By.partialLinkText("Learn more")
```

---

## XPath Locators (Use Sparingly)

Use XPath only when CSS selectors can't achieve the goal:

```java
// [!] USE WITH CAUTION: XPath for complex scenarios

// Text-based (CSS can't do this)
By.xpath("//button[text()='Submit']")
By.xpath("//button[normalize-space()='Submit']")
By.xpath("//button[contains(text(),'Submit')]")

// Parent traversal (CSS can't do this)
By.xpath("//input[@id='email']/..")
By.xpath("//input[@id='email']/ancestor::form")

// Sibling navigation
By.xpath("//label[text()='Email']/following-sibling::input")
By.xpath("//td[text()='John']/preceding-sibling::td")

// Position-based (when needed)
By.xpath("(//button[@class='action'])[1]")
By.xpath("//table//tr[last()]")

// Attribute contains
By.xpath("//input[contains(@class,'error')]")
By.xpath("//div[starts-with(@id,'product-')]")

// [no] NEVER: Absolute XPath
By.xpath("/html/body/div[1]/div[2]/form/button[3]")  // Extremely brittle!
```

---
