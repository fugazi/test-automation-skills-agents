<#
.SYNOPSIS
    Creates a new Selenium WebDriver test project with Maven structure.

.DESCRIPTION
    This script scaffolds a complete Selenium test automation project with:
    - Maven directory structure
    - Base classes (BasePage, BaseTest, WebDriverFactory)
    - Sample Page Object and Test
    - Configuration files
    - Allure reporting setup

.PARAMETER ProjectName
    The name of the project (used as artifact ID and folder name)

.PARAMETER GroupId
    The Maven group ID (default: com.example)

.PARAMETER OutputPath
    The path where the project will be created (default: current directory)

.EXAMPLE
    .\setup-maven-project.ps1 -ProjectName "my-selenium-tests"
    
.EXAMPLE
    .\setup-maven-project.ps1 -ProjectName "ecommerce-tests" -GroupId "com.mycompany" -OutputPath "C:\Projects"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory = $false)]
    [string]$GroupId = "com.example",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

# Convert group ID to path (com.example -> com/example)
$PackagePath = $GroupId -replace '\.', '/'

# Project root
$ProjectRoot = Join-Path $OutputPath $ProjectName

Write-Host "Creating Selenium test project: $ProjectName" -ForegroundColor Cyan
Write-Host "Location: $ProjectRoot" -ForegroundColor Gray

# Create directory structure
$Directories = @(
    "src/main/java/$PackagePath/base",
    "src/main/java/$PackagePath/pages",
    "src/main/java/$PackagePath/components",
    "src/main/java/$PackagePath/factories",
    "src/main/java/$PackagePath/models",
    "src/main/java/$PackagePath/utils",
    "src/main/resources",
    "src/test/java/$PackagePath/tests",
    "src/test/resources"
)

foreach ($dir in $Directories) {
    $fullPath = Join-Path $ProjectRoot $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "  Created directory structure" -ForegroundColor Green

# Create pom.xml
$PomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>$GroupId</groupId>
    <artifactId>$ProjectName</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <name>$ProjectName</name>

    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>`${java.version}</maven.compiler.source>
        <maven.compiler.target>`${java.version}</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <selenium.version>4.27.0</selenium.version>
        <junit.version>5.11.3</junit.version>
        <assertj.version>3.26.3</assertj.version>
        <allure.version>2.29.0</allure.version>
        <lombok.version>1.18.36</lombok.version>
        <slf4j.version>2.0.16</slf4j.version>
        <logback.version>1.5.12</logback.version>
        <datafaker.version>2.4.2</datafaker.version>
        <jackson.version>2.18.1</jackson.version>
        
        <maven-surefire.version>3.5.2</maven-surefire.version>
        <maven-compiler.version>3.13.0</maven-compiler.version>
        <aspectj.version>1.9.22.1</aspectj.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-java</artifactId>
            <version>`${selenium.version}</version>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>`${junit.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-params</artifactId>
            <version>`${junit.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.assertj</groupId>
            <artifactId>assertj-core</artifactId>
            <version>`${assertj.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.qameta.allure</groupId>
            <artifactId>allure-junit5</artifactId>
            <version>`${allure.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>`${lombok.version}</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>`${slf4j.version}</version>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>`${logback.version}</version>
        </dependency>
        <dependency>
            <groupId>net.datafaker</groupId>
            <artifactId>datafaker</artifactId>
            <version>`${datafaker.version}</version>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>`${jackson.version}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>`${maven-compiler.version}</version>
                <configuration>
                    <source>`${java.version}</source>
                    <target>`${java.version}</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>`${lombok.version}</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>`${maven-surefire.version}</version>
                <configuration>
                    <argLine>
                        -javaagent:"`${settings.localRepository}/org/aspectj/aspectjweaver/`${aspectj.version}/aspectjweaver-`${aspectj.version}.jar"
                    </argLine>
                    <systemPropertyVariables>
                        <allure.results.directory>`${project.build.directory}/allure-results</allure.results.directory>
                    </systemPropertyVariables>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.aspectj</groupId>
                        <artifactId>aspectjweaver</artifactId>
                        <version>`${aspectj.version}</version>
                    </dependency>
                </dependencies>
            </plugin>
            <plugin>
                <groupId>io.qameta.allure</groupId>
                <artifactId>allure-maven</artifactId>
                <version>2.14.0</version>
            </plugin>
        </plugins>
    </build>
</project>
"@

Set-Content -Path (Join-Path $ProjectRoot "pom.xml") -Value $PomContent
Write-Host "  Created pom.xml" -ForegroundColor Green

# Create config.properties
$ConfigContent = @"
# Application Configuration
base.url=http://localhost:3000

# Browser Configuration
browser=chrome
headless=false

# Timeouts (seconds)
timeout.default=15
timeout.short=5
timeout.long=30
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/resources/config.properties") -Value $ConfigContent
Write-Host "  Created config.properties" -ForegroundColor Green

# Create logback.xml
$LogbackContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>target/logs/test.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>target/logs/test.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>7</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE" />
        <appender-ref ref="FILE" />
    </root>

    <logger name="$GroupId" level="DEBUG" />
    <logger name="org.openqa.selenium" level="WARN" />
</configuration>
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/resources/logback.xml") -Value $LogbackContent
Write-Host "  Created logback.xml" -ForegroundColor Green

# Create ConfigReader.java
$ConfigReaderContent = @"
package $GroupId.utils;

import lombok.extern.slf4j.Slf4j;
import java.io.InputStream;
import java.util.Properties;

@Slf4j
public class ConfigReader {
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = ConfigReader.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (input != null) {
                properties.load(input);
                log.info("Configuration loaded successfully");
            } else {
                log.warn("config.properties not found, using defaults");
            }
        } catch (Exception e) {
            log.error("Error loading configuration", e);
        }
    }

    public static String get(String key) {
        return System.getProperty(key, properties.getProperty(key));
    }

    public static String get(String key, String defaultValue) {
        return System.getProperty(key, properties.getProperty(key, defaultValue));
    }

    public static int getInt(String key, int defaultValue) {
        String value = get(key);
        return value != null ? Integer.parseInt(value) : defaultValue;
    }

    public static boolean getBoolean(String key, boolean defaultValue) {
        String value = get(key);
        return value != null ? Boolean.parseBoolean(value) : defaultValue;
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/java/$PackagePath/utils/ConfigReader.java") -Value $ConfigReaderContent
Write-Host "  Created ConfigReader.java" -ForegroundColor Green

# Create WebDriverFactory.java
$WebDriverFactoryContent = @"
package $GroupId.factories;

import $GroupId.utils.ConfigReader;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import java.time.Duration;

@Slf4j
public class WebDriverFactory {

    public static WebDriver createDriver() {
        String browser = ConfigReader.get("browser", "chrome").toLowerCase();
        boolean headless = ConfigReader.getBoolean("headless", false);
        
        log.info("Creating WebDriver - Browser: {}, Headless: {}", browser, headless);

        WebDriver driver = switch (browser) {
            case "firefox" -> createFirefoxDriver(headless);
            case "edge" -> createEdgeDriver(headless);
            default -> createChromeDriver(headless);
        };

        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(2));
        return driver;
    }

    private static WebDriver createChromeDriver(boolean headless) {
        var options = new ChromeOptions();
        options.addArguments("--disable-notifications", "--start-maximized");
        if (headless) options.addArguments("--headless=new");
        return new ChromeDriver(options);
    }

    private static WebDriver createFirefoxDriver(boolean headless) {
        var options = new FirefoxOptions();
        if (headless) options.addArguments("-headless");
        return new FirefoxDriver(options);
    }

    private static WebDriver createEdgeDriver(boolean headless) {
        var options = new EdgeOptions();
        if (headless) options.addArguments("--headless=new");
        return new EdgeDriver(options);
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/java/$PackagePath/factories/WebDriverFactory.java") -Value $WebDriverFactoryContent
Write-Host "  Created WebDriverFactory.java" -ForegroundColor Green

# Create BasePage.java
$BasePageContent = @"
package $GroupId.base;

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

    protected BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT);
    }

    protected WebElement waitForVisible(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected WebElement waitForClickable(By locator) {
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    protected void waitForInvisible(By locator) {
        wait.until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    @Step("Click: {locator}")
    protected void click(By locator) {
        log.debug("Clicking: {}", locator);
        waitForClickable(locator).click();
    }

    @Step("Type '{text}' in: {locator}")
    protected void type(By locator, String text) {
        log.debug("Typing '{}' into: {}", text, locator);
        var element = waitForVisible(locator);
        element.clear();
        element.sendKeys(text);
    }

    protected String getText(By locator) {
        return waitForVisible(locator).getText();
    }

    protected boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    protected void waitForUrlContains(String urlPart) {
        wait.until(ExpectedConditions.urlContains(urlPart));
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/java/$PackagePath/base/BasePage.java") -Value $BasePageContent
Write-Host "  Created BasePage.java" -ForegroundColor Green

# Create BaseTest.java
$BaseTestContent = @"
package $GroupId.base;

import $GroupId.factories.WebDriverFactory;
import io.qameta.allure.Allure;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.*;
import org.openqa.selenium.*;
import java.io.ByteArrayInputStream;

@Slf4j
public abstract class BaseTest {
    protected WebDriver driver;

    @BeforeEach
    void setUp(TestInfo testInfo) {
        log.info("Starting: {}", testInfo.getDisplayName());
        driver = WebDriverFactory.createDriver();
        driver.manage().window().maximize();
    }

    @AfterEach
    void tearDown(TestInfo testInfo) {
        if (driver != null) {
            log.info("Finished: {}", testInfo.getDisplayName());
            driver.quit();
        }
    }

    protected void attachScreenshot(String name) {
        try {
            byte[] screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
            Allure.addAttachment(name, "image/png", new ByteArrayInputStream(screenshot), "png");
        } catch (Exception e) {
            log.warn("Failed to capture screenshot", e);
        }
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/test/java/$PackagePath/tests/BaseTest.java") -Value $BaseTestContent
Write-Host "  Created BaseTest.java" -ForegroundColor Green

# Create SampleTest.java
$SampleTestContent = @"
package $GroupId.tests;

import io.qameta.allure.*;
import org.junit.jupiter.api.*;
import static org.assertj.core.api.Assertions.*;

@Epic("Sample Tests")
@Feature("Verification")
class SampleTest extends BaseTest {

    @Test
    @Tag("smoke")
    @Severity(SeverityLevel.NORMAL)
    @DisplayName("Sample test - verify setup works")
    void shouldVerifySetupWorks() {
        driver.get("BASE_URL");
        
        assertThat(driver.getTitle())
            .as("Page title should contain 'Google'")
            .containsIgnoringCase("Google");
            
        attachScreenshot("google-homepage");
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/test/java/$PackagePath/tests/SampleTest.java") -Value $SampleTestContent
Write-Host "  Created SampleTest.java" -ForegroundColor Green

# Create .gitignore
$GitignoreContent = @"
# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
release.properties

# IDE
.idea/
*.iml
.vscode/
*.code-workspace

# Logs
*.log
logs/

# Test outputs
allure-results/
allure-report/
screenshots/

# OS
.DS_Store
Thumbs.db
"@

Set-Content -Path (Join-Path $ProjectRoot ".gitignore") -Value $GitignoreContent
Write-Host "  Created .gitignore" -ForegroundColor Green

# Create README.md
$ReadmeContent = @"
# $ProjectName

Selenium WebDriver test automation project.

## Prerequisites

- Java 21+
- Maven 3.9+

## Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=SampleTest

# Run with specific browser
mvn test -Dbrowser=firefox

# Run headless
mvn test -Dheadless=true

# Run smoke tests only
mvn test -Dgroups=smoke

# Generate Allure report
mvn allure:serve
```

## Project Structure

```
src/
├── main/java/$PackagePath/
│   ├── base/           # Base classes
│   ├── pages/          # Page Objects
│   ├── components/     # Reusable UI components
│   ├── factories/      # WebDriver factory
│   ├── models/         # Data models
│   └── utils/          # Utilities
├── main/resources/     # Configuration files
└── test/java/          # Test classes
```
"@

Set-Content -Path (Join-Path $ProjectRoot "README.md") -Value $ReadmeContent
Write-Host "  Created README.md" -ForegroundColor Green

Write-Host "`nProject created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. cd $ProjectName"
Write-Host "  2. mvn clean test"
Write-Host "  3. mvn allure:serve (to view report)"
