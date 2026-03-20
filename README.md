# african-econ-pipeline
# 🌍 African Economic Intelligence Pipeline

A production-style data engineering pipeline that ingests World Bank economic indicators for 48 African countries, transforms them through a layered data model, orchestrates runs with Apache Airflow, and visualises insights in Power BI.

---

## 📐 Architecture

```
World Bank API
      │
      ▼
Python (Google Colab)
  - Fetches 8 indicators × 48 countries × 24 years
  - Cleans, parses, and loads to BigQuery
      │
      ▼
Google BigQuery
  african_economics_raw.world_bank_indicators
      │
      ▼
dbt Cloud
  ├── staging:  stg_world_bank_indicators (view)
  ├── marts:    dim_countries (table)
  └── marts:    fct_economic_indicators (table)
      │
      ▼
Apache Airflow (Docker)
  - Schedules weekly pipeline runs
  - DAG: ingest → dbt staging → dbt marts
      │
      ▼
Power BI
  - Continental Overview (Page 1)
  - Country Deepdive (Page 2)
```

---

## 📊 Dashboard

The Power BI dashboard has two pages:

**Page 1 — Continental Overview**
- KPI cards: 48 countries tracked, average GDP growth, largest economy, fastest growing economy
- Africa map coloured by GDP size
- Top 10 economies bar chart
- Year slicer (2000–2023)

**Page 2 — Country Deepdive**
- Country slicer — select any of 48 countries
- KPI cards: GDP per capita, inflation rate, unemployment rate, trade % of GDP
- GDP growth rate over time (line chart)
- FDI net inflows over time (line chart)
- Inflation over time (line chart)
- Top 10 economies by GDP (bar chart)

Dashboard files are in the `/dashboard` folder (PDF and PowerPoint).

---

## 🗂️ Repository Structure

```
african-econ-pipeline/
├── ingestion/
│   └── african_econ_pipeline_m1.py   # World Bank API → BigQuery
├── dbt/
│   └── models/
│       ├── staging/
│       │   ├── sources.yml
│       │   └── stg_world_bank_indicators.sql
│       └── marts/
│           ├── dim_countries.sql
│           └── fct_economic_indicators.sql
├── dags/
│   └── african_econ_dag.py           # Airflow DAG
├── dashboard/
│   ├── African_Economic_Intelligence.pdf
│   └── African_Economic_Intelligence.pptx
├── docker-compose.yaml
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Tool |
|---|---|
| Ingestion | Python, Requests, Pandas |
| Storage | Google BigQuery |
| Transformation | dbt Cloud |
| Orchestration | Apache Airflow 2.8.1 |
| Containerisation | Docker, Docker Compose |
| Visualisation | Microsoft Power BI |
| Version Control | Git, GitHub |

---

## 📦 Data

**Source:** [World Bank Open Data API](https://data.worldbank.org/) — free, no API key required

**Countries:** 48 Sub-Saharan African countries

**Date range:** 2000–2023

**Indicators ingested:**

| Indicator | World Bank Code |
|---|---|
| GDP (current USD) | NY.GDP.MKTP.CD |
| GDP per capita (USD) | NY.GDP.PCAP.CD |
| Inflation rate (%) | FP.CPI.TOTL.ZG |
| Unemployment rate (%) | SL.UEM.TOTL.ZS |
| Trade % of GDP | NE.TRD.GNFS.ZS |
| FDI net inflows (USD) | BX.KLT.DINV.CD.WD |
| Government debt % of GDP | GC.DOD.TOTL.GD.ZS |
| Population total | SP.POP.TOTL |

---

## 🚀 How to Run

### Prerequisites
- Google Cloud account with BigQuery enabled
- dbt Cloud account connected to BigQuery
- Docker Desktop or Docker on WSL2
- Python 3.10+

### 1. Clone the repo
```bash
git clone https://github.com/chidozinyakatira/african-econ-pipeline.git
cd african-econ-pipeline
```

### 2. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 3. Run the ingestion script
Open `ingestion/african_econ_pipeline_m1.py` in Google Colab, update the `PROJECT_ID` variable and run all cells. Data will land in BigQuery.

### 4. Run dbt models
In dbt Cloud IDE:
```
dbt run
```

### 5. Start Airflow
```bash
cp .env.example .env
docker compose up airflow-init
docker compose up -d
```

Visit `http://localhost:8080` (login: airflow / airflow) and enable the `african_econ_intelligence_pipeline` DAG.

---

## 🔄 Airflow DAG

The DAG runs **weekly** and executes tasks in this order:

```
pipeline_start
      │
      ▼
ingest_world_bank_data
      │
      ▼
dbt_run_staging
      │
      ▼
dbt_run_marts
      │
      ▼
pipeline_complete
```

---

## 🧱 dbt Data Model

```
Source (BigQuery raw)
  └── world_bank_indicators
          │
          ▼
Staging (views)
  └── stg_world_bank_indicators
        - Deduplicates on ingestion_id
        - Casts all column types explicitly
        - Filters null country codes
          │
          ├──────────────────────┐
          ▼                      ▼
Marts (tables)            Marts (tables)
dim_countries             fct_economic_indicators
  - country_iso             - All indicators
  - country_name            - gdp_usd
  - region                  - gdp_yoy_growth_pct
                            - Year-over-year calculations
```

---

## 👤 Author

**Chido Zinyakatira**
- 🔗 [LinkedIn](https://www.linkedin.com/in/chido-zinyakatira-327246255)
- 💻 [GitHub](https://github.com/chidozinyakatira)
- 🌐 [Portfolio](https://github.com/chidozinyakatira/african-econ-pipeline)
- 🎓 BSc Honours Data Science — Eduvos (Distinction, 2025)
