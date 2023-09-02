# data-modelling-query-time-analysis

This project shows differences between data modelling done for OLTP systems vs that of OLAP systems.
Here, I have compared 3NF vs Star Schema.
I have also done a query time analysis comparing time taken to run a complex query on both the models.

## resouces used:

For 3NF schema I used a publicy available Postgresql dvdrental database. https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/

I tried to create a star schema data model out of this.![dvdrental_star_schema drawio](https://github.com/shailendra1394/data-modelling-query-time-analysis/assets/73093127/64fd6bfe-7352-40f7-bb5f-9ea37d1ee48d)


I used mostly pgAdmin4 for this project. Query time can be quickly monitored using this tool.


## resources created:


SQL script(dvdrental_star_schema.sql) contains DDLs/DMLs used to convert 3NF into star schema.

Jupyter notebook(data_modelling.ipynb) contains python code which showcases how to connect to postgres db using pyhton psycopg2 library.

Star schema data model diagram(dvdrental_star_schema.drawio.png).
