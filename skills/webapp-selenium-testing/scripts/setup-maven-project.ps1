<#
.SYNOPSIS
    Creates a new Selenium WebDriver test project with Maven structure.

.DESCRIPTION
    This script scaffolds a complete Selenium test automation project with:
    - Maven directory structure
    - Base classes (BasePage, BaseTest, WebDriverFactory)
    - Sample Page Object and Test
    - Configuration files

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

$PackagePath = $GroupId -replace '\.', '/'
$ProjectRoot = Join-Path $OutputPath $ProjectName

Write-Host "Creating Selenium test project: $ProjectName" -ForegroundColor Cyan
Write-Host "Location: $ProjectRoot" -ForegroundColor Gray

$Directories = @(
    "src/main/java/$PackagePath/base",
    "src/main/java/$PackagePath/pages",
    "src/main/java/$PackagePath/components",
    "src/main/java/$PackagePath/factories",
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

$PomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>$GroupId</groupId>
    <artifactId>$ProjectName</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>$ProjectName</name>
    <description>Selenium WebDriver tests with Java and JUnit 5</description>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>`${java.version}</maven.compiler.source>
        <maven.compiler.target>`${java.version}</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven-surefire.version>3.5.0</maven-surefire.version>
        <maven-compiler.version>3.13.0</maven-compiler.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.junit</groupId>
                <artifactId>junit-bom</artifactId>
                <version>5.10.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.assertj</groupId>
                <artifactId>assertj-bom</artifactId>
                <version>3.25.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.seleniumhq.selenium</groupId>
                <artifactId>selenium-bom</artifactId>
                <version>4.20.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-java</artifactId>
        </dependency>

        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.assertj</groupId>
            <artifactId>assertj-core</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <scope>test</scope>
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
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>`${maven-surefire.version}</version>
                <configuration>
                    <includes>
                        <include>**/*Test.java</include>
                    </includes>
                </configuration>
            </plugin>
        </plugins>
    </build>

    <profiles>
        <profile>
            <id>chrome</id>
            <properties>
                <browser>chrome</browser>
            </properties>
        </profile>

        <profile>
            <id>firefox</id>
            <properties>
                <browser>firefox</browser>
            </properties>
        </profile>

        <profile>
            <id>edge</id>
            <properties>
                <browser>edge</browser>
            </properties>
        </profile>

        <profile>
            <id>headless</id>
            <properties>
                <headless>true</headless>
            </properties>
        </profile>
    </profiles>
</project>
"@

Set-Content -Path (Join-Path $ProjectRoot "pom.xml") -Value $PomContent
Write-Host "  Created pom.xml" -ForegroundColor Green

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

$LogbackContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE" />
    </root>

    <logger name="$GroupId" level="DEBUG" />
    <logger name="org.openqa.selenium" level="WARN" />
</configuration>
"@

Set-Content -Path (Join-Path $ProjectRoot "src/main/resources/logback.xml") -Value $LogbackContent
Write-Host "  Created logback.xml" -ForegroundColor Green

$ConfigReaderContent = @"
package $GroupId.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.InputStream;
import java.util.Properties;

public class ConfigReader {
    private static final Logger log = LoggerFactory.getLogger(ConfigReader.class);
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

$WebDriverFactoryContent = @"
package $GroupId.factories;

import $GroupId.utils.ConfigReader;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.time.Duration;

public class WebDriverFactory {
    private static final Logger log = LoggerFactory.getLogger(WebDriverFactory.class);

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

$BasePageContent = @"
package $GroupId.base;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;
import java.time.Duration;
import java.util.List;

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

    protected void click(By locator) {
        waitForClickable(locator).click();
    }

    protected void type(By locator, String text) {
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

$BaseTestContent = @"
package $GroupId.base;

import $GroupId.factories.WebDriverFactory;
import org.junit.jupiter.api.*;
import org.openqa.selenium.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class BaseTest {
    protected WebDriver driver;
    private static final Logger log = LoggerFactory.getLogger(BaseTest.class);

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

    protected void captureScreenshot(String name) {
        try {
            File screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
            log.info("Screenshot saved: {}.png", name);
        } catch (Exception e) {
            log.warn("Failed to capture screenshot", e);
        }
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/test/java/$PackagePath/tests/BaseTest.java") -Value $BaseTestContent
Write-Host "  Created BaseTest.java" -ForegroundColor Green

$SamplePageContent = @"
package $GroupId.pages;

import $GroupId.base.BasePage;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;

public class LoginPage extends BasePage {
    
    private final By usernameInput = By.id("username");
    private final By passwordInput = By.id("password");
    private final By loginButton = By.id("login-button");
    private final By errorMessage = By.className("error-message");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    public void enterUsername(String username) {
        type(usernameInput, username);
    }

    public void enterPassword(String password) {
        type(passwordInput, password);
    }

    public void clickLogin() {
        click(loginButton);
    }

    public void login(String username, String password) {
        enterUsername(username);
        enterPassword(password);
        clickLogin();
    }

    public String getErrorMessage() {
        return getText(errorMessage);
    }

    public boolean isErrorDisplayed() {
        return isDisplayed(errorMessage);
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/test/java/$PackagePath/pages/LoginPage.java") -Value $SamplePageContent
Write-Host "  Created LoginPage.java" -ForegroundColor Green

$SampleTestContent = @"
package $GroupId.tests;

import $GroupId.base.BaseTest;
import $GroupId.pages.LoginPage;
import org.junit.jupiter.api.*;
import static org.assertj.core.api.Assertions.*;

@DisplayName("Login Tests")
class LoginTest extends BaseTest {

    private LoginPage loginPage;

    @BeforeEach
    void setUp() {
        loginPage = new LoginPage(driver);
    }

    @Test
    @DisplayName("Successful login with valid credentials")
    void shouldLoginSuccessfully() {
        driver.get("http://localhost:3000/login");
        
        loginPage.login("validUser", "validPassword");
        
        assertThat(driver.getCurrentUrl())
            .contains("/dashboard");
    }

    @Test
    @DisplayName("Error displayed with invalid credentials")
    void shouldShowErrorWithInvalidCredentials() {
        driver.get("http://localhost:3000/login");
        
        loginPage.login("invalidUser", "wrongPassword");
        
        assertThat(loginPage.isErrorDisplayed())
            .isTrue();
        assertThat(loginPage.getErrorMessage())
            .contains("Invalid credentials");
    }
}
"@

Set-Content -Path (Join-Path $ProjectRoot "src/test/java/$PackagePath/tests/LoginTest.java") -Value $SampleTestContent
Write-Host "  Created LoginTest.java" -ForegroundColor Green

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

Set-Content -JoinPath $ProjectRoot ".gitignore" -Value $GitignoreContent
Write-Host "  Created .gitignore" -ForegroundColor Green

$ReadmeContent = @"
# $ProjectName

Selenium WebDriver test automation project.

## Prerequisites

- Java 17+
- Maven 3.6+

## Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=LoginTest

# Run with specific browser
mvn test -Dbrowser=firefox

# Run headless
mvn test -Dheadless=true

# Run smoke tests only
mvn test -Dgroups=smoke
```

## Project Structure

```
src/
├── main/java/$PackagePath/
│   ├── base/           # Base classes
│   ├── pages/          # Page Objects
│   ├── components/     # Reusable UI components
│   ├── factories/      # WebDriver factory
│   └── utils/          # Utilities
├── main/resources/     # Configuration files
└── test/java/         # Test classes
```
"@

Set-Content -Path (Join-Path $ProjectRoot "README.md") -Value $ReadmeContent
Write-Host "  Created README.md" -ForegroundColor Green

Write-Host "`nProject created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. cd $ProjectName"
Write-Host "  2. Edit pom.xml to update dependency versions if needed"
Write-Host "  3. mvn clean test"
