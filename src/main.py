import time

from selenium.common.exceptions import WebDriverException
import undetected_chromedriver as uc


def main(args=None):
    TAKE_IT_EASY = True

    if args:
        TAKE_IT_EASY = (
            args.no_sleeps
        )  # so the demo is 'follow-able' instead of some flashes and boom => done. set it how you like

    if TAKE_IT_EASY:
        sleep = time.sleep
    else:
        sleep = lambda n: print(
            "we could be sleeping %d seconds here, but we don't" % n
        )

    driver = uc.Chrome()
    driver.get("https://www.google.com")

    sleep(2)  # never use this. this is for demonstration purposes only


    USELESS_SITES = [
        "https://www.trumpdonald.org",
        "https://www.isitchristmas.com",
        "https://isnickelbacktheworstbandever.tumblr.com",
        "https://www.isthatcherdeadyet.co.uk",
        "https://whitehouse.gov",
        "https://www.nsa.gov",
        "https://kimjongillookingatthings.tumblr.com",
        "https://instantrimshot.com",
        "https://www.nyan.cat",
        "https://twitter.com",
    ]

    print("opening 9 additinal windows and control them")
    sleep(1)  # never use this. this is for demonstration purposes only
    for _ in range(9):
        driver.window_new()

    print("now we got 10 windows")
    sleep(1)
    print("using the new windows to open 9 other useless sites")
    sleep(1)  # never use this. this is for demonstration purposes only

    for idx in range(1, 10):
        # skip the first handle which is our original window
        print("opening ", USELESS_SITES[idx])
        driver.switch_to.window(driver.window_handles[idx])

        # because of geographical location, (corporate) firewalls and 1001
        # other reasons why a connection could be dropped we will use a try/except clause here.
        try:
            driver.get(USELESS_SITES[idx])
        except WebDriverException as e:
            print(
                (
                    "webdriver exception. this is not an issue in chromedriver, but rather "
                    "an issue specific to your current connection. message:",
                    e.args,
                )
            )
            continue

    for handle in driver.window_handles[1:]:
        driver.switch_to.window(handle)
        print("look. %s is working" % driver.current_url)
        sleep(1)  # never use this. it is here only so you can follow along

    print(
        "close windows (including the initial one!), but keep the last new opened window"
    )
    sleep(4)  # never use this. wait until nowsecure passed the bot checks

    for handle in driver.window_handles[:-1]:
        driver.switch_to.window(handle)
        print("look. %s is closing" % driver.current_url)
        sleep(1)
        driver.close()

    # attach to the last open window
    driver.switch_to.window(driver.window_handles[0])
    print("now we only got ", driver.current_url, "left")

    sleep(1)

    driver.get("https://www.nowsecure.nl")

    sleep(5)

    driver.quit()


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--no-sleeps", "-ns", action="store_false")
    a = p.parse_args()
    main(a)