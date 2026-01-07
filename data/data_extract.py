"""
This script extracts raw Konkor exam data from cshub
and outputs konkur_results.csv used for model training.

Used only for data collection, not required at runtime.
"""

from bs4 import BeautifulSoup
import pandas as pd

with open("cshub.ir.html", "r", encoding="utf-8") as f:
    soup = BeautifulSoup(f.read(), "html.parser")

rows = []
for tr in soup.find_all("tr"):
    tds = [td.get_text(strip=True) for td in tr.find_all(["td", "th"])]
    if tds:
        rows.append(tds)

df = pd.DataFrame(rows)
df.to_csv("konkur_results.csv", index=False, encoding="utf-8-sig")
print("Saved as konkur_results.csv")