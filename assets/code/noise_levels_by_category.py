# Noise levels by category (bar chart with percentages) — saves PNG
# Requires: pandas, matplotlib, re
import os, re
import pandas as pd
import matplotlib.pyplot as plt

file_path = r'C:\Users\bhutt\OneDrive\Documents\ny\noise_levels_by_category.csv'
df = pd.read_csv(file_path)

def extract_numeric(value: str) -> float:
    s = str(value).strip()
    if '-' in s:
        a, b = s.split('-', 1)
        return (float(re.sub(r'[^\d.]', '', a)) + float(re.sub(r'[^\d.]', '', b))) / 2.0
    if '/' in s:
        a, b = s.split('/', 1)
        return (float(re.sub(r'[^\d.]', '', a)) + float(re.sub(r'[^\d.]', '', b))) / 2.0
    m = re.sub(r'[^\d.]', '', s)
    return float(m) if m else 0.0

category_colors = {
    'Home': '#1f78b4',
    'Work': '#33a02c',
    'Recreation': '#e31a1c'
}

all_vals, all_labels, all_colors = [], [], []
for category in df.columns:
    series = df[category].dropna().astype(str)
    # expecting "75 Home appliance", etc.
    vals = [extract_numeric(x.split(' ')[0]) for x in series]
    labels = [' '.join(x.split(' ')[1:]) for x in series]
    all_vals.extend(vals)
    all_labels.extend(labels)
    all_colors.extend([category_colors.get(category, '#666666')] * len(labels))

total = sum(all_vals) or 1.0
percentages = [(v / total) * 100.0 for v in all_vals]
labels_pct = [f"{lbl} ({pct:.1f}%)" for lbl, pct in zip(all_labels, percentages)]

os.makedirs("assets/plots", exist_ok=True)
plt.figure(figsize=(16, 9))
plt.bar(labels_pct, all_vals, color=all_colors)
plt.xticks(rotation=90, fontsize=11)
plt.ylabel('Noise level (dBA)')
plt.title('Noise levels by source (with share %)')  # illustrative
plt.grid(axis='y')
plt.margins(x=0)
plt.tight_layout()
plt.savefig("assets/plots/noise_levels_by_category.png", dpi=200, bbox_inches="tight")
# plt.show()

