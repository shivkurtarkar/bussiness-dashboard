# Problem statement
This project aims at exploring how bussinesses can use data engineering tools to quickly setup and understand their operations better using data. By using data bussinesses can shift from making decsions from biased gut feeling to data leveraged insights.
Here are some example quetions ecommerse Bussiness operator would be interested in understanding.
- Sales: How much revenue is the eCommerce business generating? What are the top-selling products? What are the trends in sales over time?
- Customer Acquisition: How are customers finding the eCommerce business? What channels are most effective for acquiring new customers? What is the customer acquisition cost (CAC)?
- Inventory Management: How much inventory is available? What is the turnover rate for each product? What are the inventory carrying costs? What is the lead time for replenishing inventory?
- Shipping and Fulfillment: How long does it take to fulfill orders? What is the shipping cost for each order? What is the return rate? What is the customer satisfaction rate for shipping and fulfillment?



# Dataset
In this project we are using sales data as an example. Every day at the end of bussiness day, new sales data would be generated. And we can schedule batch job to generate insights.

We are using [eCommerce purchase history from electronics store](https://www.kaggle.com/datasets/mkechinov/ecommerce-purchase-history-from-electronics-store) data. This dataset contains purchase data from April 2020 to November 2020 from a large home appliances and electronics online store. 

## Overview

1. Data ingestion - Download dataset and ingest it in data lake(GCP Bucket)
2. Data warehouse - This data is imported into Big Query for performing anlytics.
3. Transformations - We are using dbt to transform data to suitable schema and store in BigQuery.
4. Dashboard - Looker Studio, formerly Google Data Studio is using as a dashboard to visualize the results.



# Steps to setup infrastructure using Terraform
```
refresh service-accounts auth token for this session
gcloud auth application-defualt login


terraform init

terraform plan -var="project=<gcp-project-id>"
```
```
# Create new infra
terraform apply -var="project=<gcp-project-id>"
```

```
# Delete infra after your work, to avoid cost on any running
terraform destroy
```

# Project Description

## 1. Data ingestion

```
make prefect-docker-build
make prefect-docker-compose-run
```

```
make build-kaggle-download-step
make run-kaggle-download-step
```
```
make build-bq-import-step
make run-import-bq-step
```
## 2. Data warehouse

## 3. Transformations
```
make dbt-docker-build
make dbt-dev-env
```

## 4. Dashboard 
Pdf of the dashboard can be found [here](./05_dashboard/DE_Sales_Report.pdf)
And here is access to dashboard [here](https://lookerstudio.google.com/s/nZ_rDTE-aZg)

The dashboard tries to answer following quetions
- what is monthly and daily sales trend.
- what is the peak hours of sales.
- Total sales for current year. 
- Total Number of orders for current year.
- Average order price
- Sales ranking by brand for last 4,12, 24 and 52 weeks.

## References
### Article inspiration: 
[PBI Use Case #2: How healthy is your Inventory?](https://medium.com/@dfme69/how-healthy-is-your-inventory-69d40468dfdc)

