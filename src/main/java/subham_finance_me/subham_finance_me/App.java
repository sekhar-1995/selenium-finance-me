package subham_finance_me.subham_finance_me;
import java.io.IOException;
import org.openqa.selenium.WebDriver;
//import org.apache.commons.io.FileUtils;
//import org.openqa.selenium.OutputType;
//import java.io.File;
//import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.By;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
public class App {
	//@SuppressWarnings({ "deprecation" })
	public static void main(final String[] args) throws InterruptedException, IOException {
		System.setProperty("webdriver.chrome.driver", "/usr/bin/chromedriver");
		//System.setProperty("webdriver.chrome.driver", "C:\\Users\\subha\\eclipse-workspace\\chromedriver.exe");
		final ChromeOptions chromeOptions = new ChromeOptions();
		chromeOptions.addArguments("--remote-allow-origins=*", "ignore-certificate-errors");
		chromeOptions.addArguments(new String[] { "--headless" });
		chromeOptions.addArguments(new String[] { "--no-sandbox" });
		chromeOptions.addArguments(new String[] { "--disable-dev-shm-usage" });
		final WebDriver driver = (WebDriver) new ChromeDriver(chromeOptions);
		driver.get("http://52.91.38.123:8082/contact.html");
		driver.manage().timeouts().implicitlyWait(5L, TimeUnit.SECONDS);
		driver.findElement(By.name("Name")).sendKeys("Subham");
		driver.findElement(By.name("Phone Number")).sendKeys("9999999999");
		driver.findElement(By.name("Email")).sendKeys("subhamsekharsekhar@gmail.com");
		driver.findElement(By.name("Message")).sendKeys("Welcome to the Finance-me Project");
		driver.findElement(By.name("SEND")).click();
		final String message = driver.findElement(By.id("message")).getText();
		if (message.equals("Email Sent")) {
			System.out.println("Script executed Successfully");
		} else {
			System.out.println("Script failed");
		}
		Thread.sleep(3000L);
		driver.quit();
		}
}
