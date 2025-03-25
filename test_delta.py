#%pyspark
from pyspark.sql import SparkSession
from delta import configure_spark_with_delta_pip

builder = SparkSession.builder.appName("DeltaTest") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.jars.packages", f"io.delta:delta-core_2.12:2.4.0,io.delta:delta-storage:2.4.0")

spark = configure_spark_with_delta_pip(builder).getOrCreate()

df = spark.createDataFrame([(1, "teste")], ["id", "nome"])
df.createOrReplaceTempView('tb_teste')
df.write.format("delta").mode("overwrite").save("/tmp/delta_table")

print("Tabela Delta criada com sucesso!")