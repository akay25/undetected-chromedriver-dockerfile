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

    driver.get("https://www.nowsecure.nl")
    sleep(10)
    driver.quit()


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--no-sleeps", "-ns", action="store_false")
    a = p.parse_args()
    main(a)