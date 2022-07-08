const puppeteer = require('puppeteer');
const fs = require('fs');


(async () => {

    const browser = await puppeteer.launch({
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            "--disable-gpu",
            "--disable-dev-shm-usage"
        ]
    });


    const page = await browser.newPage();


    await page.goto('https://apply.commonapp.org/login', { waitUntil: 'networkidle2' });

    await page.type('#loginEmailControl', '', { delay: 90 })
    await page.type('#loginPasswordControl', '', { delay: 110 })
    
    await page.click('#loginSubmit');
    await page.waitForNavigation({ waitUntil: 'networkidle2' });
    await page.screenshot({ path: 'after_login.png' });

    
    await page.waitFor(3000)
    await page.screenshot({ path: 'after_dashboard_load.png' });
    

    // Sniff for the right API response
    // puppeteer captures the request twice - once as a 'preflight' and once as the actual request
    // so the GET filter is to make sure we capture the right one
    page.on('response', async (response) => {
        if (response.url() == "https://api21.commonapp.org/datacatalog/members/requirements") {
            if(response.request().method() == 'GET') {
                const text = await response.text();
                fs.writeFileSync('common_app_colleges.json', text);
            }
        }
    });
    await page.goto('https://apply.commonapp.org/requirements?myColleges=true', { waitUntil: 'networkidle2' });
    await page.waitFor(3000);
    await page.screenshot({ path: 'after_requirements_grid.png' });


    await page.close();
    await browser.close();

})();