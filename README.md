# Problem statement
This project aims at exploring how bussinesses can use data engineering tools to quickly setup and understand their operations better using data. By using data bussinesses can shift from making decsions from biased gut feeling to data leveraged insights.
Here are some quetions ecommerse Bussiness operator would be interested in understanding.
- Sales: How much revenue is the eCommerce business generating? What are the top-selling products? What are the trends in sales over time?
- Customer Acquisition: How are customers finding the eCommerce business? What channels are most effective for acquiring new customers? What is the customer acquisition cost (CAC)?
- Customer Retention: What is the customer retention rate? How often do customers make repeat purchases? What is the customer lifetime value (CLV)?
- Marketing: What marketing strategies are most effective in driving traffic and sales? What is the return on ad spend (ROAS)? What is the customer acquisition cost (CAC) for each marketing channel?
- Website Traffic: How much traffic is the website receiving? What are the top sources of traffic? What is the bounce rate? What is the conversion rate?
- Inventory Management: How much inventory is available? What is the turnover rate for each product? What are the inventory carrying costs? What is the lead time for replenishing inventory?
- Shipping and Fulfillment: How long does it take to fulfill orders? What is the shipping cost for each order? What is the return rate? What is the customer satisfaction rate for shipping and fulfillment?
- Customer Service: What is the average response time for customer inquiries? What is the customer satisfaction rate for customer service interactions? What are the most common customer complaints or issues?
- Financials: What are the expenses associated with running the eCommerce business? What is the net profit margin? What is the cash flow situation? Are there any financial risks or challenges?
- Competition: What are the main competitors in the eCommerce business? What are their strengths and weaknesses? How does the eCommerce business differentiate itself from the competition?

In this project we are using Sales data as an example.

# Dataset



## Overview
1. Data ingestion
2. Data warehouse
3. Transformations
4. Dashboard

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
google data studio
looker [here](https://lookerstudio.google.com/s/nZ_rDTE-aZg)

## References
### Dataset: 
[eCommerce purchase history from electronics store](https://www.kaggle.com/datasets/mkechinov/ecommerce-purchase-history-from-electronics-store)

### Article inspiration: 
[PBI Use Case #2: How healthy is your Inventory?](https://medium.com/@dfme69/how-healthy-is-your-inventory-69d40468dfdc)

