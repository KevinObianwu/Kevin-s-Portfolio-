#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium import webdriver
import time
import os
import datetime
import shutil


downloads_folder = r"C:\Users\DOSHEA1\Downloads"
destination_folder = r"\\thameswater.sharepoint.com@SSL\DavWWWRoot\sites\ThamesWater-WaterNetworksHub\SitePages\Customer"
file_name_prefix = "Complaints_Data_Download"


# Replace this with your PowerBI dashboard link
dashboard_link = "https://app.powerbi.com/groups/me/reports/c0a3e964-be3a-4c71-af40-90d4a6d3a5fd/ReportSectiondf64ef389ba37d6d459e?ctid=557abecd-3214-4fbb-8e51-414b68ebb796&experience=power-bi&bookmarkGuid=84be68e5-1670-408e-9c7e-976e57d3165c"

# Create a new instance of the Edge driver
driver = webdriver.Edge()

try:
    # Open the PowerBI login page
    driver.get(dashboard_link)

    # Wait for the PowerBI dashboard to load (you might need to adjust the time based on your internet speed)
    time.sleep(5)

    # Check if the element with the specified data-test-id attribute is present
    element_with_data_test_id = driver.find_element(By.CSS_SELECTOR, "[data-test-id='david.oshea@thameswater.co.uk']")
    element_with_data_test_id.click()

    # You may need to add additional wait time or logic to handle the next steps after clicking the element

except NoSuchElementException:
    print("Element with data-test-id 'david.oshea@thameswater.co.uk' not found")

# Wait for the export data button to load
time.sleep(15)

try:
    # Find the "More options" button and click it
    more_options_button = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[aria-label='More options']"))
    )
    more_options_button.click()

except TimeoutException:
    print("Timed out waiting for 'More options' button")

# Wait for the export data options to load
time.sleep(5)

# Choose the desired export option (CSV, Excel, etc.)
# For example, if you want to export as CSV:
export_csv_option = driver.find_element(By.XPATH, "//button[@title='Export data']//span[text()='Export data']")
export_csv_option.click()

# Wait for the download to complete (you might need to adjust the time based on your data size)
time.sleep(5)

# Find the "Export" button and click it
export_button = driver.find_element(By.CSS_SELECTOR, "[data-testid='export-btn']")
export_button.click()

# Wait for the download to complete (you might need to adjust the time based on your data size)
time.sleep(10)

# Close the browser
driver.quit()

# Wait for the download to complete
time.sleep(20)  # Adjust the sleep duration based on the time it takes for the download to complete

# Get the list of files in the Downloads folder
downloaded_files = [f for f in os.listdir(downloads_folder) if os.path.isfile(os.path.join(downloads_folder, f))]

# Find the latest downloaded file
latest_download = max(downloaded_files, key=lambda x: os.path.getctime(os.path.join(downloads_folder, x)))
# ... (previous code)
# ... (previous code)

# Construct the new file name with the desired prefix and extension
new_file_name = f"{file_name_prefix}.xlsx"
new_file_path = os.path.join(downloads_folder, new_file_name)
destination_file_path = os.path.join(destination_folder, new_file_name)  # Use new_file_name directly

try:
    # Delete the existing file from the destination folder if it already exists
    if os.path.exists(destination_file_path):
        os.remove(destination_file_path)
        print(f"Deleted existing file: '{new_file_name}' in '{destination_folder}'")

    # Copy the file to the destination folder with the correct extension
    shutil.copyfile(os.path.join(downloads_folder, latest_download), destination_file_path)

    # Remove the original file from the Downloads folder
    os.remove(os.path.join(downloads_folder, latest_download))

    # Output the path of the moved file
    print(f"File '{new_file_name}' moved to '{destination_folder}'")
except Exception as e:
    print(f"Error moving file: {e}")

