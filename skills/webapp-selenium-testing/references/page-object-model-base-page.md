# Page Object Model Base Page Pattern

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

## Base Page Pattern

Create a base class with common functionality:

```java
package com.project.base;

import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;
import java.time.Duration;
import java.util.List;

@Slf4j
public abstract class BasePage {
    protected final WebDriver driver;
    protected final WebDriverWait wait;
    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(15);
    private static final Duration POLL_INTERVAL = Duration.ofMillis(500);

    protected BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT, POLL_INTERVAL);
    }

    // ============ WAIT METHODS ============

    protected WebElement waitForVisible(By locator) {
        log.debug("Waiting for element visible: {}", locator);
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected WebElement waitForClickable(By locator) {
        log.debug("Waiting for element clickable: {}", locator);
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    protected void waitForInvisible(By locator) {
        log.debug("Waiting for element invisible: {}", locator);
        wait.until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    protected void waitForUrlContains(String urlPart) {
        log.debug("Waiting for URL to contain: {}", urlPart);
        wait.until(ExpectedConditions.urlContains(urlPart));
    }

    protected void waitForTextPresent(By locator, String text) {
        wait.until(ExpectedConditions.textToBePresentInElementLocated(locator, text));
    }

    // ============ ACTION METHODS ============

    @Step("Click on element: {locator}")
    protected void click(By locator) {
        log.info("Clicking: {}", locator);
        waitForClickable(locator).click();
    }

    @Step("Enter text '{text}' in field: {locator}")
    protected void type(By locator, String text) {
        log.info("Typing '{}' into: {}", text, locator);
        var element = waitForVisible(locator);
        element.clear();
        element.sendKeys(text);
    }

    @Step("Clear and type '{text}' in field: {locator}")
    protected void clearAndType(By locator, String text) {
        var element = waitForVisible(locator);
        element.sendKeys(Keys.chord(Keys.CONTROL, "a"), text);
    }

    @Step("Select option '{visibleText}' from dropdown: {locator}")
    protected void selectByVisibleText(By locator, String visibleText) {
        log.info("Selecting '{}' from: {}", visibleText, locator);
        var select = new Select(waitForVisible(locator));
        select.selectByVisibleText(visibleText);
    }

    @Step("Select option by value '{value}' from dropdown: {locator}")
    protected void selectByValue(By locator, String value) {
        var select = new Select(waitForVisible(locator));
        select.selectByValue(value);
    }

    // ============ GETTER METHODS ============

    protected String getText(By locator) {
        return waitForVisible(locator).getText();
    }

    protected String getAttribute(By locator, String attribute) {
        return waitForVisible(locator).getAttribute(attribute);
    }

    protected String getValue(By locator) {
        return getAttribute(locator, "value");
    }

    protected List<WebElement> findAll(By locator) {
        return driver.findElements(locator);
    }

    protected List<String> getAllTexts(By locator) {
        return findAll(locator).stream()
            .map(WebElement::getText)
            .toList();
    }

    // ============ STATE METHODS ============

    protected boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    protected boolean isEnabled(By locator) {
        return waitForVisible(locator).isEnabled();
    }

    protected boolean isSelected(By locator) {
        return waitForVisible(locator).isSelected();
    }

    protected int countElements(By locator) {
        return driver.findElements(locator).size();
    }

    // ============ UTILITY METHODS ============

    @Step("Take screenshot: {name}")
    protected byte[] takeScreenshot(String name) {
        log.info("Taking screenshot: {}", name);
        return ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
    }

    protected void scrollToElement(By locator) {
        var element = waitForVisible(locator);
        ((JavascriptExecutor) driver).executeScript(
            "arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});",
            element
        );
    }

    protected void jsClick(By locator) {
        var element = waitForVisible(locator);
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", element);
    }
}
```

---
