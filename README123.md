# 🧪 Gherkin + TestCafe Automation Framework

This repository contains an end-to-end automation testing setup using **TestCafe** with **Gherkin (Cucumber syntax)** support. It enables writing readable and maintainable test cases in BDD format.

---

## ✅ Prerequisites

Before setting up the project, ensure the following are installed on your machine:

- [Node.js (v14+)](https://nodejs.org/en/)
- npm (comes with Node.js)
- Git (for version control)

---

## 🚀 Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/your-org/your-testcafe-gherkin-project.git
cd your-testcafe-gherkin-project
npm install
```

---

## 🧰 Project Structure

```
├── features/               # Gherkin feature files
│   └── sample.feature
├── step-definitions/       # Step definitions for Gherkin steps
│   └── sample-steps.js
├── testcafe-config/        # Custom TestCafe configuration (optional)
├── reports/                # HTML and JSON reports will be generated here
├── package.json            # Project metadata and scripts
├── .testcaferc.json        # TestCafe configuration file
└── README.md               # You're reading this!
```

---

## 📝 Writing Tests (Gherkin)

Feature files use the standard Gherkin syntax:

```gherkin
Feature: Login functionality

  Scenario: Successful login
    Given I open the login page
    When I enter valid credentials
    Then I should be redirected to the dashboard
```

---

## 🧑‍💻 Step Definitions

Each step in the feature file must be mapped to a function in a JS file inside `step-definitions/`:

```js
import { Given, When, Then } from '@cucumber/cucumber';
import { Selector } from 'testcafe';

Given('I open the login page', async () => {
  await testController.navigateTo('https://your-app-url.com/login');
});

When('I enter valid credentials', async () => {
  await testController
    .typeText('#username', 'testuser')
    .typeText('#password', 'password123')
    .click('#login-button');
});

Then('I should be redirected to the dashboard', async () => {
  await testController.expect(Selector('h1').innerText).eql('Dashboard');
});
```

---

## ▶️ Test Execution

Run tests using the following command:

```bash
npm test
```

Or run with specific tags or browsers:

```bash
npx testcafe chrome ./features --cucumber-tag @login
```

---

## 🧾 Report Generation

Install reporting tools (if not already in `package.json`):

```bash
npm install testcafe-reporter-html --save-dev
```

Update your `package.json` to include reporter:

```json
"scripts": {
  "test": "testcafe chrome features/**/*.feature --reporter html:reports/report.html"
}
```

After running tests, open the HTML report from:

```
reports/report.html
```

---

## 🏷️ Tagging Scenarios

To run only tagged tests:

```gherkin
@smoke
Scenario: Quick smoke test
```

```bash
npx testcafe chrome ./features --cucumber-tag @smoke
```

---

## 🧪 Useful Commands

- Run tests on Firefox:
  ```bash
  npx testcafe firefox features/
  ```

- Run tests headlessly:
  ```bash
  npx testcafe chrome:headless features/
  ```

- Filter scenarios by name:
  ```bash
  npx testcafe chrome features/ --test "Successful login"
  ```

---

## 📂 References

- [TestCafe Docs](https://testcafe.io/documentation)
- [Gherkin Syntax](https://cucumber.io/docs/gherkin/)
- [TestCafe Gherkin Integration](https://github.com/kiwigrid/testcafe-cucumber)

---

## 👨‍💻 Author

Harish Kumar  
Software Automation Test Engineer  
📫 usa.harish@gmail.com
