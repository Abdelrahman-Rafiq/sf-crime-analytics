# 🚨 San Francisco Crime Analytics & Pipeline

An end-to-end data engineering and analytics project querying the **San Francisco DataSF Socrata API**, ingesting raw JSON payloads into a **PostgreSQL relational database**, and analyzing primary incident records to extract actionable public safety insights.

---

## 🛠️ Architecture & Tech Stack

* **Extraction:** Python (`requests`) querying Socrata Open Data API (SODA)
* **Storage:** PostgreSQL (relational database schema, views, custom data types)
* **Pipeline & Processing:** Python (`psycopg2`, `SQLAlchemy`, `pandas`)
* **EDA & Visualization:** Jupyter Notebook, `Seaborn`, `Matplotlib`, `Folium` (Interactive Mapping)

```text
DataSF API ──> Python Ingestion ──> PostgreSQL Database ──> SQL Views ──> Pandas / EDA ──> Executive Insights
```

---

## 📁 Repository Structure

```text
|
├── scripts/
│   ├── 01_fetch_and_ingest.py       # API extraction & PostgreSQL pipeline
│   └── 02_db_cleaning.sql          # SQL schema & volume analysis view
├── notebooks/
│   └── 03_crime_eda_analysis.ipynb  # Visualizations, spatial maps & analysis
└── README.md                        # Documentation & executive summary
```

---

## 📌 Executive Summary

### 📊 Key Findings

* **Dominant Crime Category:** Larceny Theft is the most frequently recorded crime category, accounting for **35.26%** of all reported incidents.
* **Temporal Patterns:** Crime incidents vary considerably throughout the year. **2018** recorded the highest number of incidents, while **2020** saw a significant decline. At the monthly level, **July and August** recorded the highest number of incidents, whereas **November** recorded the lowest.
* **Peak Crime Hours:** **12 PM (noon)** recorded the highest number of incidents, followed by **12 AM (midnight)**. The lowest number of incidents occurred around **5 AM**.
* **Day-of-Week Pattern:** **Friday** recorded the highest number of incidents, while **Sunday** recorded the lowest.
* **Spatial Distribution:** The **Central** police district recorded the highest number of incidents, accounting for approximately **16.53%** of the total, while the **Park** district recorded the lowest.

## 🗺️ Spatial Analysis

The heatmap below shows the geographical distribution of reported
crime incidents across San Francisco.

![Crime Heatmap](notebooks/crime_heatmap.png)

### 🌐 Interactive Crime Heatmap

[Open the Interactive Heatmap](https://abdelrahman-rafiq.github.io/sf-crime-analytics/maps/crime_heatmap.html)
---

### 💡 Strategic Recommendations

1. **Optimize Patrol Scheduling:**  
   Increase police presence around identified peak periods, particularly **midday and midnight**, while adjusting shifts to reflect lower overnight volume (5 AM).
2. **Prioritize High-Volume Districts:**  
   Focus resource allocation on the **Central** district (**16.53% of total incidents**). Spatial heatmap analysis pinpoints exact commercial corridors requiring foot patrols.
3. **Target Larceny Theft:**  
   Since **Larceny Theft represents 35.26%** of all offenses, deploy targeted theft-prevention measures including public surveillance, improved lighting, and high-visibility property protection campaigns.
4. **Seasonal Planning:**  
   Scale up public safety staffing and crime prevention initiatives during peak summer months (**July and August**).
5. **Monitor Long-Term Trends:**  
   Track the post-2022 decline in reported incidents to evaluate potential reporting shifts versus genuine policy and prevention successes.

---

## ⚡ Quickstart & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Abdelrahman-Rafiq/sf-crime-analytics.git
   cd sf-crime-analytics
   ```

2. **Install dependencies:**
   ```bash
   pip install requests psycopg2-binary pandas sqlalchemy seaborn matplotlib folium
   ```

3. **Run database setup & API ingestion:**
   ```bash
   python scripts/01_fetch_and_ingest.py
   ```

4. **Launch EDA Notebook:**
   ```bash
   jupyter notebook notebooks/03_crime_eda_analysis.ipynb
   ```

