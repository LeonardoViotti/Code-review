#------------------------------------------------------------------------------#

#			Rwanda Feeder Roads
#           GPS tracking raw data checks

#------------------------------------------------------------------------------#

# Porpuse: Processes raw data of GPS tracking to produce completness
# checks

# WARNING: This depends on _master.py to run!

#------------------------------------------------------------------------------#

EXPORT = True

# Import functions
from pyspark.sql.functions import year, hour, month, to_date
from pyspark.sql.functions import col, countDistinct, count, lit

from _master import *

# Settings
dates = '2019_October'
file_name = 'positions_' + dates + '.csv'

#------------------------------------------------------------------------------#
# Load data

#dbutils.fs.ls('mnt/SpeedGovernorsTrackingData')
#braw = spark.read.csv('dbfs:/mnt/SpeedGovernorsTrackingData/devices_2019_02.csv')
braw = spark\
    .read.options(header= True, inferSchema= True)\
    .csv(BCARS_RAW + file_name)

# Columns
# braw.printSchema()

# Register the DataFrame as a SQL temporary view
# braw.createOrReplaceTempView("braw")

#------------------------------------------------------------------------------#
# Checks

# braw.select('devicetime').show(5)

# Create time vars
braw = braw.withColumn('hour', hour(col('devicetime')))
braw = braw.withColumn('date', to_date(col('devicetime')))

# Count hours per day
agg_braw = braw\
    .groupBy('date')\
    .agg(countDistinct('hour'),
         countDistinct('deviceid'),
         count(lit(1)).alias("Num Of Records"))\
    .orderBy('date')

# agg_braw =
agg_braw = agg_braw\
    .withColumnRenamed("count(DISTINCT hour)", "n hours")\
    .withColumnRenamed("count(DISTINCT deviceid)", "n devices")

if EXPORT:
    save_name = BCARS_HFC + dates + '.csv'
    #agg_braw.write.csv(save_name)
    agg_braw.toPandas().to_csv(save_name,
                               index = False)
else:
    agg_braw.show(250)

# Export to csv
